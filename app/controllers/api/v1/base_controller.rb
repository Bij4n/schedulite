module API
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_key!
      before_action :set_tenant

      private

      def authenticate_api_key!
        @api_key = APIKey.authenticate(request.headers["X-API-Key"])
        render json: { error: "Unauthorized" }, status: :unauthorized unless @api_key
      end

      def set_tenant
        ActsAsTenant.current_tenant = @api_key.tenant
      end
    end
  end
end
