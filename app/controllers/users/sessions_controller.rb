module Users
  class SessionsController < Devise::SessionsController
    after_action :record_sign_in, only: :create, if: -> { current_user.present? }
    after_action :record_sign_out, only: :destroy

    private

    # Audit logging must never break authentication. If the login_events
    # table is missing (migrations didn't run) or the DB hiccups, log and
    # move on — the user is already signed in and Devise has already issued
    # the session cookie by the time this after_action fires.
    def record_sign_in
      LoginEvent.record_sign_in(current_user, request)
    rescue => e
      Rails.logger.error("[LoginEvent] sign_in audit failed: #{e.class} #{e.message}")
    end

    def record_sign_out
      LoginEvent.record_sign_out(resource, request) if resource
    rescue => e
      Rails.logger.error("[LoginEvent] sign_out audit failed: #{e.class} #{e.message}")
    end
  end
end
