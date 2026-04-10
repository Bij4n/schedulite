class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  set_current_tenant_through_filter
  before_action :set_tenant

  # Temporary: log every uncaught exception to STDOUT with a recognizable
  # tag so it's findable in Render's log stream. Re-raises so Rails still
  # serves the public/500.html page.
  rescue_from StandardError do |e|
    Rails.logger.error("[SCHEDULITE-500] #{e.class}: #{e.message}")
    Rails.logger.error("[SCHEDULITE-500] path=#{request.fullpath} method=#{request.method}")
    Rails.logger.error("[SCHEDULITE-500] trace: #{e.backtrace.first(15).join(' | ')}")
    raise
  end

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
