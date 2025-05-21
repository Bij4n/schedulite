module Settings
  class AnalyticsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @summary = AnalyticsService.daily_summary(tenant: current_user.tenant)
      @no_show_rate = AnalyticsService.no_show_rate(tenant: current_user.tenant, date_range: 30.days.ago..Date.current)
      @avg_wait = AnalyticsService.average_wait_minutes(tenant: current_user.tenant, date_range: 30.days.ago..Date.current)
      @utilization = AnalyticsService.provider_utilization(tenant: current_user.tenant, date_range: 30.days.ago..Date.current)
    end

    def export
      authorize_export!
      appointments = Appointment.where(tenant: current_user.tenant)
                                .where(starts_at: 30.days.ago..Time.current)
                                .includes(:patient, :provider)
                                .order(:starts_at)

      csv_data = generate_csv(appointments)
      send_data csv_data, filename: "appointments_export_#{Date.current}.csv", type: "text/csv"
    end

    private

    def generate_csv(appointments)
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << ["Date", "Time", "Patient", "Provider", "Status", "Delay (min)"]
        appointments.each do |appt|
          csv << [
            appt.starts_at.to_date,
            appt.starts_at.strftime("%-l:%M %p"),
            appt.patient.display_name,
            appt.provider.display_name,
            appt.status.humanize,
            appt.delay_minutes
          ]
        end
      end
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.admin?
    end

    def authorize_export!
      redirect_to root_path, alert: "Not authorized" if current_user.front_desk?
    end
  end
end
