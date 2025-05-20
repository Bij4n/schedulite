module Users
  class SessionsController < Devise::SessionsController
    after_action :record_sign_in, only: :create, if: -> { current_user.present? }
    after_action :record_sign_out, only: :destroy

    private

    def record_sign_in
      LoginEvent.record_sign_in(current_user, request)
    end

    def record_sign_out
      LoginEvent.record_sign_out(resource, request) if resource
    end
  end
end
