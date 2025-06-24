class SmsService
  def self.call(patient:, appointment:, template:, **extra_vars)
    new(patient: patient, appointment: appointment, template: template, **extra_vars).call
  end

  def initialize(patient:, appointment:, template:, **extra_vars)
    @patient = patient
    @appointment = appointment
    @template = template
    @extra_vars = extra_vars
  end

  def call
    unless twilio_configured?
      Rails.logger.warn("Twilio not configured — skipping SMS to #{@patient.id}")
      return
    end

    body = render_body
    response = send_via_twilio(body)
    record_message(body, response.sid)
  rescue Twilio::REST::TwilioError => e
    Rails.logger.error("SMS delivery failed for patient #{@patient.id}: #{e.message}")
    nil
  end

  private

  def twilio_configured?
    account_sid.present? && auth_token.present?
  end

  def render_body
    SmsTemplate.render(@template, template_variables)
  end

  def template_variables
    {
      first_name: @patient.first_name,
      appointment_time: @appointment.starts_at.strftime("%-l:%M %p"),
      provider_name: @appointment.provider.display_name,
      status_url: status_url,
      **@extra_vars
    }
  end

  def status_url
    "#{base_url}/status/#{@appointment.signed_token}"
  end

  def base_url
    ENV.fetch("APP_HOST", "http://localhost:3000")
  end

  def send_via_twilio(body)
    client = Twilio::REST::Client.new(account_sid, auth_token)

    client.messages.create(
      to: formatted_phone,
      from: phone_number,
      body: body
    )
  end

  def account_sid
    Rails.application.credentials.dig(:twilio, :account_sid)
  end

  def auth_token
    Rails.application.credentials.dig(:twilio, :auth_token)
  end

  def phone_number
    Rails.application.credentials.dig(:twilio, :phone_number)
  end

  def formatted_phone
    phone = @patient.phone.gsub(/\D/, "")
    phone = "1#{phone}" if phone.length == 10
    "+#{phone}"
  end

  def record_message(body, twilio_sid)
    SmsMessage.create!(
      appointment: @appointment,
      patient: @patient,
      direction: :outbound,
      body: body,
      twilio_sid: twilio_sid
    )
  end
end
