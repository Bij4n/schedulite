class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_by_role, only: :index

  def index
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @view_mode = params[:view] || "list"
    @selected_provider_id = params[:provider_id]
    @tenant = current_user.tenant
    @providers = Provider.order(:last_name)

    @week_start = @selected_date.beginning_of_week(:monday)
    @week_dates = (0..6).map { |i| @week_start + i.days }

    week_appointments = Appointment.where(starts_at: @week_start.beginning_of_day..(@week_start + 6.days).end_of_day)
                                   .includes(:patient, :provider)

    if @selected_provider_id.present?
      week_appointments = week_appointments.where(provider_id: @selected_provider_id)
    end

    @day_counts = week_appointments.group_by { |a| a.starts_at.to_date }
                                   .transform_values(&:count)

    if @view_mode == "week"
      @week_appointments = week_appointments.sort_by(&:starts_at).group_by { |a| a.starts_at.to_date }
    else
      day_appointments = week_appointments.select { |a| a.starts_at.to_date == @selected_date }
                                          .sort_by(&:starts_at)
      @morning = day_appointments.select { |a| a.starts_at.hour < 12 }
      @afternoon = day_appointments.select { |a| a.starts_at.hour >= 12 }
    end

    @lunch_configured = @tenant.lunch_start.present? && @tenant.lunch_end.present?
    @lunch_start = @tenant.lunch_start
    @lunch_end = @tenant.lunch_end
  end

  private

  def redirect_by_role
    case current_user.role
    when "provider"
      redirect_to provider_dashboard_path unless params[:force] == "admin"
    when "staff"
      redirect_to staff_dashboard_path unless params[:force] == "admin"
    end
  end
end
