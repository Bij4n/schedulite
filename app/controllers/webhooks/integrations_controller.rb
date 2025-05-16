module Webhooks
  class IntegrationsController < ActionController::Base
    skip_forgery_protection

    def create
      integration = Integration.find_by(id: params[:integration_id])
      return head :not_found unless integration

      adapter = Integrations::AdapterFactory.build(integration)
      return head :forbidden unless adapter.verify_webhook(request)

      dto = adapter.parse_webhook(request.raw_post)

      ActsAsTenant.with_tenant(integration.tenant) do
        Integrations::SyncJob.new.send(:upsert_appointment, integration.tenant, dto)
      end

      head :ok
    end
  end
end
