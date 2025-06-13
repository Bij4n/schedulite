module Settings
  class TimesheetController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_week(:monday)
      @end_date = @start_date + 6.days
      @staff = User.where(tenant: current_user.tenant).order(:last_name)

      @entries = TimeEntry.where(user: @staff)
                          .where(clock_in_at: @start_date.beginning_of_day..@end_date.end_of_day)
                          .includes(:user)
                          .order(:clock_in_at)

      @staff_hours = @entries.group_by(&:user).transform_values do |entries|
        entries.select(&:clock_out_at).sum(&:duration_hours).round(1)
      end
    end

    def export
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_week(:monday)
      @end_date = @start_date + 6.days
      @staff = User.where(tenant: current_user.tenant)

      entries = TimeEntry.where(user: @staff)
                         .where(clock_in_at: @start_date.beginning_of_day..@end_date.end_of_day)
                         .completed
                         .includes(:user)
                         .order(:clock_in_at)

      csv = generate_csv(entries)
      send_data csv, filename: "timesheet_#{@start_date}_#{@end_date}.csv", type: "text/csv"
    end

    private

    def generate_csv(entries)
      require "csv"
      CSV.generate(headers: true) do |csv|
        csv << ["Staff", "Date", "Clock In", "Clock Out", "Break (min)", "Hours"]
        entries.each do |e|
          csv << [e.user.full_name, e.clock_in_at.to_date, e.clock_in_at.strftime("%-l:%M %p"),
                  e.clock_out_at&.strftime("%-l:%M %p"), e.break_minutes_taken, e.duration_hours.round(1)]
        end
      end
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.manager?
    end
  end
end
