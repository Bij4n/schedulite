module Portal
  class ProfileController < BaseController
    before_action :authenticate_patient!

    def show
    end

    def update
      if current_patient.update(profile_params)
        redirect_to portal_profile_path, notice: "Profile updated"
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:patient).permit(:email, :address, :city, :state, :zip)
    end
  end
end
