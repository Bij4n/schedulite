module Settings
  class StaffController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @staff = User.where(tenant: current_user.tenant).order(:last_name)
    end

    def create
      @user = User.new(staff_params)
      @user.tenant = current_user.tenant
      @user.password = SecureRandom.hex(16) # Temporary password, user should reset

      if @user.save
        redirect_to settings_staff_index_path, notice: "Staff member added"
      else
        @staff = User.where(tenant: current_user.tenant).order(:last_name)
        render :index, status: :unprocessable_entity
      end
    end

    def update
      @user = User.find(params[:id])
      if @user.update(staff_params)
        redirect_to settings_staff_index_path, notice: "Staff member updated"
      else
        redirect_to settings_staff_index_path, alert: "Update failed"
      end
    end

    def destroy
      @user = User.find(params[:id])
      if @user == current_user
        redirect_to settings_staff_index_path, alert: "Cannot remove yourself"
      else
        @user.destroy
        redirect_to settings_staff_index_path, notice: "Staff member removed"
      end
    end

    private

    def staff_params
      params.require(:user).permit(:first_name, :last_name, :email, :role)
    end

    def authorize_admin!
      unless current_user.owner? || current_user.manager?
        redirect_to root_path, alert: "Not authorized"
      end
    end
  end
end
