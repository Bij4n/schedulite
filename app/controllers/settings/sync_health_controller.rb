module Settings
  class SyncHealthController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @integrations = Integration.includes(:provider).order(:created_at)
      @error_count = @integrations.count { |i| i.sync_status == :error }
    end

    private

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.manager?
    end
  end
end
