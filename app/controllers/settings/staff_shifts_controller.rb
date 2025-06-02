module Settings
  class StaffShiftsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @staff_member = User.find(params[:staff_id])
      @shifts = @staff_member.staff_shifts.order(:day_of_week)
      @weekly_hours = @shifts.select(&:active?).sum(&:hours)
    end

    def create
      @staff_member = User.find(params[:staff_id])
      @shift = @staff_member.staff_shifts.build(shift_params)
      @shift.status = "proposed"

      if @shift.save
        redirect_to settings_staff_shifts_path(@staff_member), notice: "Shift proposed"
      else
        redirect_to settings_staff_shifts_path(@staff_member), alert: @shift.errors.full_messages.join(", ")
      end
    end

    def approve
      @staff_member = User.find(params[:staff_id])
      @shift = @staff_member.staff_shifts.find(params[:id])
      @shift.update!(status: "active")
      redirect_to settings_staff_shifts_path(@staff_member), notice: "Shift approved and activated"
    end

    def destroy
      @staff_member = User.find(params[:staff_id])
      @shift = @staff_member.staff_shifts.find(params[:id])
      @shift.destroy!
      redirect_to settings_staff_shifts_path(@staff_member), notice: "Shift removed"
    end

    private

    def shift_params
      params.require(:staff_shift).permit(:day_of_week, :start_time, :end_time, :break_minutes)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.admin?
    end
  end
end
