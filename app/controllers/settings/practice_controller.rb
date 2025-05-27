module Settings
  class PracticeController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @tenant = current_user.tenant
    end

    def update
      @tenant = current_user.tenant
      if @tenant.update(practice_params)
        redirect_to settings_practice_path, notice: "Practice settings updated"
      else
        flash.now[:alert] = @tenant.errors.full_messages.join(", ")
        render :show, status: :unprocessable_entity
      end
    end

    private

    def practice_params
      params.require(:tenant).permit(:name, :lunch_start, :lunch_end)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.admin?
    end
  end
end
