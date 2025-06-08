class TimeOffRequestsController < ApplicationController
  before_action :authenticate_user!

  def create
    @request = current_user.time_off_requests.build(time_off_params)
    @request.status = "pending"

    if @request.save
      redirect_to settings_profile_path, notice: "Time-off request submitted"
    else
      redirect_to settings_profile_path, alert: @request.errors.full_messages.join(", ")
    end
  end

  def approve
    @request = TimeOffRequest.find(params[:id])
    @request.update!(status: "approved", approved_by: current_user, responded_at: Time.current)
    redirect_back fallback_location: settings_time_off_path, notice: "Time off approved"
  end

  def reject
    @request = TimeOffRequest.find(params[:id])
    @request.update!(status: "rejected", approved_by: current_user, responded_at: Time.current)
    redirect_back fallback_location: settings_time_off_path, notice: "Time off rejected"
  end

  private

  def time_off_params
    params.require(:time_off_request).permit(:start_date, :end_date, :request_type, :reason)
  end
end
