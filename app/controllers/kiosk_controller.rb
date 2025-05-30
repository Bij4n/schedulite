class KioskController < ActionController::Base
  layout "kiosk"

  def show
    @tenant = Tenant.find_by!(subdomain: params[:subdomain])
  end

  def check_in
    @tenant = Tenant.find_by!(subdomain: params[:subdomain])
    phone = params[:phone]&.gsub(/\D/, "")

    ActsAsTenant.with_tenant(@tenant) do
      patient = Patient.find_by(phone: phone)

      if patient.nil?
        redirect_to kiosk_path(subdomain: @tenant.subdomain), alert: "We couldn't find your phone number. Please check with the front desk."
        return
      end

      appointment = patient.appointments.today.where(status: :scheduled).chronological.first

      if appointment.nil?
        redirect_to kiosk_path(subdomain: @tenant.subdomain), alert: "No appointment found for today. Please check with the front desk."
        return
      end

      StatusChangeService.call(appointment: appointment, user: nil, new_status: "checked_in")
      redirect_to kiosk_confirmed_path(subdomain: @tenant.subdomain, token: appointment.signed_token)
    end
  end

  def confirmed
    @tenant = Tenant.find_by!(subdomain: params[:subdomain])
    @appointment = Appointment.find_by!(signed_token: params[:token])
  end
end
