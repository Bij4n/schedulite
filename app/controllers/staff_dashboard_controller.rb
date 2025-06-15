class StaffDashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @appointments = Appointment.today.chronological.includes(:patient, :provider)
    @clocked_in = current_user.time_entries.where(status: "in_progress").any?
    @current_entry = current_user.time_entries.where(status: "in_progress").first
  end
end
