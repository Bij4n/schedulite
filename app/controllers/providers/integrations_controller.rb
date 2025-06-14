module Providers
  class IntegrationsController < ApplicationController
    before_action :authenticate_user!

    CALENDAR_TYPES = [
      { type: "google_calendar", name: "Google Calendar", fields: %w[calendar_id client_id client_secret] },
      { type: "outlook", name: "Microsoft Outlook", fields: %w[client_id client_secret tenant_id] },
      { type: "apple_calendar", name: "Apple Calendar (iCloud)", fields: %w[apple_id app_specific_password calendar_url] },
      { type: "calendly", name: "Calendly", fields: %w[api_key webhook_signing_key organization_uri] },
      { type: "acuity", name: "Acuity Scheduling", fields: %w[user_id api_key] },
      { type: "cal_com", name: "Cal.com", fields: %w[api_key] },
      { type: "ical", name: "iCal Feed (Any)", fields: %w[feed_url] }
    ].freeze

    def new
      @provider = Provider.find(params[:provider_id])
      @calendar_types = CALENDAR_TYPES
      @selected_type = CALENDAR_TYPES.find { |t| t[:type] == params[:type] }
    end

    def create
      @provider = Provider.find(params[:provider_id])

      creds = {}
      type_config = CALENDAR_TYPES.find { |t| t[:type] == params[:adapter_type] }
      type_config&.dig(:fields)&.each do |field|
        creds[field] = params.dig(:credentials, field) if params.dig(:credentials, field).present?
      end

      integration = Integration.new(
        tenant: current_user.tenant,
        provider: @provider,
        adapter_type: params[:adapter_type],
        credentials: creds,
        status: "active"
      )

      if integration.save
        redirect_to provider_path(@provider), notice: "Calendar connected"
      else
        redirect_to new_provider_integration_path(@provider), alert: integration.errors.full_messages.join(", ")
      end
    end

    def destroy
      @provider = Provider.find(params[:provider_id])
      integration = @provider.integrations.find(params[:id])
      integration.destroy!
      redirect_to provider_path(@provider), notice: "Calendar disconnected"
    end
  end
end
