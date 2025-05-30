class PatientStatusController < ActionController::Base
  layout "patient_status"

  def show
    @appointment = Appointment.includes(:patient, :provider, :gift_cards).find_by!(signed_token: params[:token])

    # Calculate queue position
    if @appointment.checked_in? || @appointment.scheduled?
      ahead = Appointment.where(tenant: @appointment.tenant, provider: @appointment.provider)
                         .where(status: [:checked_in, :in_room])
                         .where("starts_at < ?", @appointment.starts_at)
                         .count
      @patients_ahead = ahead
    end
  rescue ActiveRecord::RecordNotFound
    render plain: "Not found", status: :not_found
  end
end
