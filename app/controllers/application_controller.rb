class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  set_current_tenant_through_filter
  before_action :set_tenant

  private

  def set_tenant
    return unless current_user

    set_current_tenant(current_user.tenant)
  end
end
