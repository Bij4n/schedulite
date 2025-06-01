module Providers
  class SchedulesController < ApplicationController
    before_action :authenticate_user!

    def create
      @provider = Provider.find(params[:provider_id])
      @schedule = @provider.provider_schedules.build(schedule_params)
      @schedule.proposed_by = current_user
      @schedule.status = "pending"

      if @schedule.save
        redirect_to provider_path(@provider), notice: "Schedule proposed — awaiting approval"
      else
        redirect_to provider_path(@provider), alert: @schedule.errors.full_messages.join(", ")
      end
    end

    def approve
      @schedule = ProviderSchedule.find(params[:id])
      @schedule.update!(status: "approved", approved_at: Time.current)
      redirect_to provider_path(@schedule.provider), notice: "Schedule approved"
    end

    def reject
      @schedule = ProviderSchedule.find(params[:id])
      @schedule.update!(status: "rejected", notes: params[:notes])
      redirect_to provider_path(@schedule.provider), notice: "Schedule rejected"
    end

    def destroy
      @schedule = ProviderSchedule.find(params[:id])
      provider = @schedule.provider
      @schedule.destroy!
      redirect_to provider_path(provider), notice: "Schedule removed"
    end

    private

    def schedule_params
      params.require(:provider_schedule).permit(:day_of_week, :start_time, :end_time, :slot_duration_minutes)
    end
  end
end
