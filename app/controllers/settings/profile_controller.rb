module Settings
  class ProfileController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def update
      if current_user.update(profile_params)
        redirect_to settings_profile_path, notice: "Profile updated"
      else
        flash.now[:alert] = current_user.errors.full_messages.join(", ")
        render :show, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
  end
end
