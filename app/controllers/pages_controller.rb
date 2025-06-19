class PagesController < ApplicationController
  skip_before_action :set_tenant

  def home
    if current_user
      case current_user.role
      when "owner", "manager"
        redirect_to dashboard_index_path
      when "provider"
        redirect_to provider_dashboard_path
      when "staff"
        redirect_to staff_dashboard_path
      end
    else
      render layout: "landing"
    end
  end

  def privacy
    render layout: "landing"
  end

  def terms
    render layout: "landing"
  end

  def hipaa
    render layout: "landing"
  end

  def security
    render layout: "landing"
  end

  def integrations_directory
    render layout: "landing"
  end
end
