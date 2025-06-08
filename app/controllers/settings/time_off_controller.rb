module Settings
  class TimeOffController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @pending = TimeOffRequest.joins(:user).where(users: { tenant_id: current_user.tenant_id }).pending.includes(:user).order(:start_date)
      @upcoming = TimeOffRequest.joins(:user).where(users: { tenant_id: current_user.tenant_id }).approved.upcoming.includes(:user)
    end

    private

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.admin?
    end
  end
end
