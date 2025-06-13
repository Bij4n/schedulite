module Settings
  class PracticeController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @tenant = current_user.tenant
    end

    def update
      @tenant = current_user.tenant

      # Convert dollar input to cents for no-show fee
      if params[:tenant][:no_show_fee_dollars].present?
        dollars = params[:tenant][:no_show_fee_dollars].to_f
        params[:tenant][:no_show_fee_cents] = (dollars * 100).round
      elsif params[:tenant].key?(:no_show_fee_dollars)
        params[:tenant][:no_show_fee_cents] = 0
      end

      if @tenant.update(practice_params)
        redirect_to settings_practice_path, notice: "Practice settings updated"
      else
        flash.now[:alert] = @tenant.errors.full_messages.join(", ")
        render :show, status: :unprocessable_entity
      end
    end

    private

    def practice_params
      params.require(:tenant).permit(:name, :lunch_start, :lunch_end, :no_show_fee_cents,
        :default_shift_start, :default_shift_end, :default_break_minutes,
        :max_hours_per_week, :required_lunch_minutes)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.manager?
    end
  end
end
