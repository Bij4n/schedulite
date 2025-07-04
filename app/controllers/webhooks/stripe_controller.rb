module Webhooks
  class StripeController < ActionController::API
    def create
      event = Stripe::Webhook.construct_event(
        request.body.read,
        request.env["HTTP_STRIPE_SIGNATURE"],
        Rails.application.credentials.dig(:stripe, :webhook_secret)
      )

      case event.type
      when "checkout.session.completed"
        handle_checkout_completed(event.data.object)
      when "customer.subscription.updated"
        handle_subscription_updated(event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      end

      head :ok
    rescue Stripe::SignatureVerificationError
      head :bad_request
    end

    private

    def handle_checkout_completed(session)
      tenant_id = session["metadata"]["tenant_id"]
      plan = session["metadata"]["plan"]
      tenant = Tenant.find_by(id: tenant_id)
      return unless tenant

      tenant.update!(
        plan: plan,
        stripe_customer_id: session["customer"],
        stripe_subscription_id: session["subscription"]
      )
    end

    def handle_subscription_updated(subscription)
      tenant = Tenant.find_by(stripe_customer_id: subscription["customer"])
      return unless tenant

      tenant.update!(
        stripe_subscription_id: subscription["id"],
        billing_period_end: subscription["current_period_end"] ? Time.at(subscription["current_period_end"]) : nil
      )
    end

    def handle_subscription_deleted(subscription)
      tenant = Tenant.find_by(stripe_customer_id: subscription["customer"])
      return unless tenant

      tenant.update!(
        plan: "free",
        stripe_subscription_id: nil,
        stripe_price_id: nil,
        billing_period_end: nil
      )
    end
  end
end
