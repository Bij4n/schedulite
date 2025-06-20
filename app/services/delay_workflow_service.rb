class DelayWorkflowService
  def self.execute(template:, provider:, triggered_by:, delay_minutes:, gift_card_enabled: false)
    new(template: template, provider: provider, triggered_by: triggered_by,
        delay_minutes: delay_minutes, gift_card_enabled: gift_card_enabled).execute
  end

  def self.process_reply(patient_phone:, reply_text:)
    new_for_reply.process_reply(patient_phone: patient_phone, reply_text: reply_text)
  end

  def initialize(template: nil, provider: nil, triggered_by: nil, delay_minutes: nil, gift_card_enabled: false)
    @template = template
    @provider = provider
    @triggered_by = triggered_by
    @delay_minutes = delay_minutes
    @gift_card_enabled = gift_card_enabled
  end

  def execute
    affected = find_affected_appointments
    return nil if affected.empty?

    workflow = create_workflow(affected.count)
    notify_patients(workflow, affected)
    workflow
  end

  def self.process_patient_reply(patient_phone:, reply_text:)
    phone = patient_phone.gsub(/\D/, "").last(10)
    patient = Patient.find_by(phone: phone)
    return unless patient

    # Find the most recent active workflow response for this patient
    response = DelayWorkflowResponse
      .joins(:delay_workflow)
      .where(patient: patient, response: "no_response")
      .where(delay_workflows: { status: "active" })
      .order(created_at: :desc)
      .first
    return unless response

    choice = reply_text.strip

    case choice
    when "1"
      handle_wait(response)
    when "2"
      handle_reschedule(response)
    when "3"
      handle_cancel(response)
    end
  end

  private

  def find_affected_appointments
    @provider.appointments
             .where(starts_at: Time.current..Time.current.end_of_day)
             .where(status: [:scheduled, :checked_in])
             .includes(:patient)
             .order(:starts_at)
  end

  def create_workflow(count)
    DelayWorkflow.create!(
      tenant: @provider.tenant,
      provider: @provider,
      triggered_by: @triggered_by,
      template: @template,
      delay_minutes: @delay_minutes,
      gift_card_enabled: @gift_card_enabled,
      affected_appointment_count: count,
      started_at: Time.current,
      status: "active"
    )
  end

  def notify_patients(workflow, appointments)
    appointments.each do |appointment|
      patient = appointment.patient

      # Create response tracker
      DelayWorkflowResponse.create!(
        delay_workflow: workflow,
        appointment: appointment,
        patient: patient,
        response: "no_response"
      )

      # Build and send SMS
      next unless patient.sms_consent? && patient.phone.present?

      message = build_message(appointment)
      send_sms(patient, appointment, message)

      # Shift appointment time
      new_time = appointment.starts_at + @delay_minutes.minutes
      appointment.update!(delay_minutes: @delay_minutes)
    end
  end

  def build_message(appointment)
    variables = {
      provider_name: @provider.display_name,
      delay_minutes: @delay_minutes.to_s,
      original_time: appointment.starts_at.strftime("%-l:%M %p"),
      new_time: (appointment.starts_at + @delay_minutes.minutes).strftime("%-l:%M %p")
    }

    msg = @template.render_message(variables)
    msg += "\n\n" + @template.response_options

    if @gift_card_enabled
      msg += "\n\nAs a thank you for your patience, we'll send you a gift card if you choose to wait."
    end

    msg
  end

  def send_sms(patient, appointment, message)
    SmsService.call(
      patient: patient,
      appointment: appointment,
      template: :delay_workflow,
      custom_body: message
    )
  rescue => e
    Rails.logger.error("Delay workflow SMS failed for patient #{patient.id}: #{e.message}")
  end

  def self.handle_wait(response)
    response.update!(response: "waiting", responded_at: Time.current)

    # Issue gift card if enabled
    if response.delay_workflow.gift_card_enabled?
      GiftCardIssuanceService.call(appointment: response.appointment)
      response.update!(gift_card_issued: true)
    end
  end

  def self.handle_reschedule(response)
    response.update!(response: "rescheduling", responded_at: Time.current)
    # Staff will follow up to reschedule
  end

  def self.handle_cancel(response)
    response.update!(response: "canceling", responded_at: Time.current)
    StatusChangeService.call(
      appointment: response.appointment,
      user: nil,
      new_status: "canceled",
      note: "Canceled by patient via delay workflow"
    )
  end
end
