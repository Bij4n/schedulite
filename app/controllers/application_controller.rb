class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  set_current_tenant_through_filter
  before_action :set_tenant

  private

  def set_tenant
    return unless current_user

    set_current_tenant(current_user.tenant)
  end

  def after_sign_in_path_for(resource)
    case resource.role
    when "owner", "manager" then dashboard_index_path
    when "provider" then provider_dashboard_path
    when "staff" then staff_dashboard_path
    else dashboard_index_path
    end
  end
end
