class PatientStatusController < ActionController::Base
  layout "patient_status"

  def show
    @appointment = Appointment.includes(:patient, :provider, :gift_cards).find_by!(signed_token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render plain: "Not found", status: :not_found
  end
end
