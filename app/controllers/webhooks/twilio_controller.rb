module Webhooks
  class TwilioController < ActionController::Base
    skip_forgery_protection

    def create
      phone = normalize_phone(params[:From])
      patient = Patient.find_by(phone: phone)

      if patient
        handle_consent_keywords(patient, params[:Body])
        record_inbound_message(patient, params[:Body], params[:MessageSid])
      end

      render xml: "<Response></Response>", content_type: "text/xml"
    end

    private

    def handle_consent_keywords(patient, body)
      keyword = body&.strip&.upcase
      case keyword
      when "STOP"
        patient.update!(sms_consent: false, sms_opted_out_at: Time.current)
      when "START"
        patient.update!(sms_consent: true, sms_opted_out_at: nil)
      end
    end

    def record_inbound_message(patient, body, twilio_sid)
      appointment = patient.appointments.today.order(starts_at: :desc).first
      return unless appointment

      SmsMessage.create!(
        appointment: appointment,
        patient: patient,
        direction: :inbound,
        body: body,
        twilio_sid: twilio_sid
      )
    end

    def normalize_phone(phone)
      phone&.gsub(/\D/, "")&.last(10)
    end
  end
end
