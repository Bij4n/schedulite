class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    all_appointments = Appointment.today.chronological.includes(:patient, :provider)
    @tenant = current_user.tenant

    @morning = all_appointments.select { |a| a.starts_at.hour < 12 }
    @afternoon = all_appointments.select { |a| a.starts_at.hour >= 12 }

    @lunch_configured = @tenant.lunch_start.present? && @tenant.lunch_end.present?
    @lunch_start = @tenant.lunch_start
    @lunch_end = @tenant.lunch_end
  end
end
