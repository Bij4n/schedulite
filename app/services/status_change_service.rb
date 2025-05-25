class StatusChangeService
  Result = Struct.new(:success?, :error, keyword_init: true)

  VALID_TRANSITIONS = {
    "scheduled" => %w[checked_in running_late no_show canceled complete],
    "checked_in" => %w[in_room running_late no_show complete],
    "in_room" => %w[running_late complete],
    "running_late" => %w[checked_in in_room complete no_show canceled],
    "complete" => [],
    "no_show" => %w[checked_in],
    "canceled" => []
  }.freeze

  def self.call(appointment:, user:, new_status:, delay_minutes: nil, note: nil)
    new(appointment: appointment, user: user, new_status: new_status, delay_minutes: delay_minutes, note: note).call
  end

  def initialize(appointment:, user:, new_status:, delay_minutes: nil, note: nil)
    @appointment = appointment
    @user = user
    @new_status = new_status.to_s
    @delay_minutes = delay_minutes
    @note = note
  end

  def call
    return Result.new(success?: false, error: invalid_transition_message) unless valid_transition?

    from_status = @appointment.status

    ActiveRecord::Base.transaction do
      @appointment.update!(
        status: @new_status,
        delay_minutes: @delay_minutes || @appointment.delay_minutes
      )

      StatusEvent.create!(
        appointment: @appointment,
        user: @user,
        from_status: from_status,
        to_status: @new_status,
        delay_minutes: @delay_minutes,
        note: @note
      )
    end

    send_notifications(from_status)

    Result.new(success?: true, error: nil)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, error: e.message)
  end

  private

  def send_notifications(from_status)
    return unless @appointment.patient.sms_consent?

    case @new_status
    when "checked_in"
      send_sms(:check_in_confirmation)
    when "running_late"
      send_sms(:delay_notice, delay_minutes: @delay_minutes || 0)
      GiftCardIssuanceService.call(appointment: @appointment)
    when "in_room"
      send_sms(:youre_next) if from_status == "running_late"
    end
  end

  def send_sms(template, **extra)
    SmsService.call(
      patient: @appointment.patient,
      appointment: @appointment,
      template: template,
      **extra
    )
  rescue => e
    Rails.logger.error("SMS send failed for appointment #{@appointment.id}: #{e.message}")
  end

  def valid_transition?
    allowed = VALID_TRANSITIONS.fetch(@appointment.status, [])
    allowed.include?(@new_status)
  end

  def invalid_transition_message
    "Cannot transition from #{@appointment.status} to #{@new_status}"
  end
end
