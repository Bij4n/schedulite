module Settings
  class IntegrationsController < ApplicationController
    before_action :authenticate_user!

    def index
      @integrations = Integration.where(tenant: current_user.tenant)
    end

    def destroy
      integration = Integration.find(params[:id])
      integration.destroy!
      redirect_to settings_integrations_path, notice: "Integration disconnected"
    end
  end
end
