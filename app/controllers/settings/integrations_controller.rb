module Settings
  class IntegrationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    AVAILABLE_INTEGRATIONS = [
      # EHR Systems
      { type: "fhir", name: "FHIR R4 (Epic, Athena, Cerner)", fields: %w[base_url client_id client_secret], description: "Connect any EHR that supports FHIR R4 via SMART-on-FHIR", category: "ehr" },
      # Calendars & Scheduling
      { type: "google_calendar", name: "Google Calendar", fields: %w[calendar_id client_id client_secret], description: "Import events from Google Calendar", category: "calendar" },
      { type: "outlook", name: "Microsoft Outlook", fields: %w[client_id client_secret tenant_id], description: "Sync from Outlook 365 calendar via Microsoft Graph API", category: "calendar" },
      { type: "apple_calendar", name: "Apple Calendar (iCloud)", fields: %w[apple_id app_specific_password calendar_url], description: "Sync from iCloud Calendar via CalDAV", category: "calendar" },
      { type: "calendly", name: "Calendly", fields: %w[api_key webhook_signing_key organization_uri], description: "Sync appointments from Calendly via webhooks", category: "calendar" },
      { type: "acuity", name: "Acuity Scheduling", fields: %w[user_id api_key], description: "Sync from Acuity (Squarespace Scheduling)", category: "calendar" },
      { type: "cal_com", name: "Cal.com", fields: %w[api_key], description: "Open-source scheduling — sync appointments via API", category: "calendar" },
      { type: "zoho_bookings", name: "Zoho Bookings", fields: %w[client_id client_secret refresh_token], description: "Sync from Zoho Bookings appointment scheduler", category: "calendar" },
      { type: "setmore", name: "Setmore", fields: %w[api_key], description: "Free online appointment scheduling", category: "calendar" },
      { type: "ical", name: "iCal Feed (Any)", fields: %w[feed_url provider_name], description: "Subscribe to any .ics calendar feed — works with most calendar apps", category: "calendar" },
      # Practice Management
      { type: "jane_app", name: "Jane App", fields: %w[api_key clinic_id], description: "Allied health — PT, chiro, mental health. Popular in Canada.", category: "pms" },
      { type: "simple_practice", name: "SimplePractice", fields: %w[access_token], description: "Mental health and private practice management", category: "pms" },
      { type: "nex_health", name: "NexHealth", fields: %w[api_key subdomain location_id], description: "Dental + medical PMS aggregator — one integration, many systems", category: "pms" },
      { type: "drchrono", name: "DrChrono", fields: %w[client_id client_secret], description: "Cloud-based EHR and practice management", category: "pms" },
      { type: "kareo", name: "Kareo / Tebra", fields: %w[api_key practice_id], description: "Medical billing and practice management", category: "pms" },
      { type: "open_dental", name: "Open Dental", fields: %w[api_key], description: "Dental practice management software", category: "pms" }
    ].freeze

    def index
      @integrations = Integration.all
      @available = AVAILABLE_INTEGRATIONS
    end

    def new
      @integration_type = AVAILABLE_INTEGRATIONS.find { |i| i[:type] == params[:type] }
      redirect_to settings_integrations_path, alert: "Unknown integration type" unless @integration_type
    end

    def create
      integration = Integration.new(
        adapter_type: params[:adapter_type],
        credentials: credential_params,
        status: "active"
      )

      if integration.save
        redirect_to settings_integrations_path, notice: "#{params[:adapter_type].humanize} connected"
      else
        flash[:alert] = integration.errors.full_messages.join(", ")
        redirect_to new_settings_integration_path(type: params[:adapter_type])
      end
    end

    def destroy
      integration = Integration.find(params[:id])
      integration.destroy!
      redirect_to settings_integrations_path, notice: "Integration disconnected"
    end

    private

    def credential_params
      creds = {}
      type_config = AVAILABLE_INTEGRATIONS.find { |i| i[:type] == params[:adapter_type] }
      return creds unless type_config

      type_config[:fields].each do |field|
        creds[field] = params.dig(:credentials, field) if params.dig(:credentials, field).present?
      end
      creds
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner? || current_user.manager?
    end
  end
end
