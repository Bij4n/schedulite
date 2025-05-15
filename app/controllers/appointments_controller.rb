class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @appointment = Appointment.includes(:patient, :provider, :status_events).find(params[:id])
  end
end
