class TimeClockController < ApplicationController
  before_action :authenticate_user!

  def clock_in
    existing = current_user.time_entries.in_progress.first
    if existing
      redirect_back fallback_location: root_path, alert: "Already clocked in"
      return
    end

    TimeEntry.create!(
      user: current_user,
      clock_in_at: Time.current,
      status: "in_progress",
      ip_address: request.remote_ip
    )
    redirect_back fallback_location: root_path, notice: "Clocked in"
  end

  def clock_out
    entry = current_user.time_entries.in_progress.first
    if entry
      entry.update!(clock_out_at: Time.current, status: "completed")
      redirect_back fallback_location: root_path, notice: "Clocked out (#{entry.duration_hours.round(1)} hrs)"
    else
      redirect_back fallback_location: root_path, alert: "Not clocked in"
    end
  end
end
