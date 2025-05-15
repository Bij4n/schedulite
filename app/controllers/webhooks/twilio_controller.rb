module Webhooks
  class TwilioController < ActionController::Base
    skip_forgery_protection

    def create
      phone = normalize_phone(params[:From])
      patient = Patient.find_by(phone: phone)

      if patient
        appointment = patient.appointments.today.order(starts_at: :desc).first

        if appointment
          SmsMessage.create!(
            appointment: appointment,
            patient: patient,
            direction: :inbound,
            body: params[:Body],
            twilio_sid: params[:MessageSid]
          )
        end
      end

      render xml: "<Response></Response>", content_type: "text/xml"
    end

    private

    def normalize_phone(phone)
      phone&.gsub(/\D/, "")&.last(10)
    end
  end
end
