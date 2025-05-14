class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointments = Appointment.today.chronological.includes(:patient, :provider)
  end
end
