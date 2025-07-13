module Portal
  class SessionsController < BaseController
    def new
    end

    def request_link
      phone_digits = params[:phone].to_s.gsub(/\D/, "").last(10)
      patient = Patient.find_by(phone: phone_digits) if phone_digits.length == 10

      if patient
        token = SecureRandom.urlsafe_base64(32)
        patient.update!(
          magic_link_token: token,
          magic_link_expires_at: 15.minutes.from_now
        )
        send_link_sms(patient, token)
      end

      # Always redirect with the same message — never reveal whether the phone exists
      redirect_to portal_login_path, notice: "If we found your account, we sent you a sign-in link."
    end

    def authenticate
      patient = Patient.find_by(magic_link_token: params[:token])

      if patient && patient.magic_link_expires_at && patient.magic_link_expires_at > Time.current
        patient.update!(magic_link_token: nil, magic_link_expires_at: nil)
        sign_in_patient(patient)
        redirect_to portal_appointments_path
      else
        redirect_to portal_login_path, alert: "Invalid or expired link"
      end
    end

    def destroy
      sign_out_patient
      redirect_to portal_login_path
    end

    private

    def send_link_sms(patient, token)
      url = "#{ENV.fetch('APP_HOST', 'http://localhost:3000')}/portal/auth/#{token}"
      latest = patient.appointments.order(starts_at: :desc).first
      return unless latest

      SmsService.call(
        patient: patient,
        appointment: latest,
        template: :magic_link,
        link: url
      )
    rescue => e
      Rails.logger.error("Failed to send magic link: #{e.message}")
    end
  end
end
