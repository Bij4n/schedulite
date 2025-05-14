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

    ActiveRecord::Base.transaction do
      from_status = @appointment.status

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

    Result.new(success?: true, error: nil)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, error: e.message)
  end

  private

  def valid_transition?
    allowed = VALID_TRANSITIONS.fetch(@appointment.status, [])
    allowed.include?(@new_status)
  end

  def invalid_transition_message
    "Cannot transition from #{@appointment.status} to #{@new_status}"
  end
end
