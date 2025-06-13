module Settings
  class IntegrationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    AVAILABLE_INTEGRATIONS = [
      { type: "fhir", name: "FHIR R4 (Epic, Athena, Cerner)", fields: %w[base_url client_id client_secret], description: "Connect any EHR that supports FHIR R4 via SMART-on-FHIR" },
      { type: "calendly", name: "Calendly", fields: %w[api_key webhook_signing_key organization_uri], description: "Sync appointments from Calendly via webhooks" },
      { type: "google_calendar", name: "Google Calendar", fields: %w[calendar_id client_id client_secret], description: "Import events from a Google Calendar" },
      { type: "jane_app", name: "Jane App", fields: %w[api_key clinic_id], description: "Sync from Jane App (PT, chiro, mental health)" },
      { type: "simple_practice", name: "SimplePractice", fields: %w[access_token], description: "Connect your SimplePractice account" },
      { type: "acuity", name: "Acuity Scheduling", fields: %w[user_id api_key], description: "Sync from Acuity (Squarespace Scheduling)" },
      { type: "nex_health", name: "NexHealth", fields: %w[api_key subdomain location_id], description: "Connect via NexHealth PMS aggregator" },
      { type: "ical", name: "iCal Feed", fields: %w[feed_url provider_name], description: "Subscribe to any .ics calendar feed" }
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
