module Settings
  class BillingController < ApplicationController
    before_action :authenticate_user!
    before_action :require_owner_or_manager

    PRICE_IDS = {
      "pro" => ENV.fetch("STRIPE_PRO_PRICE_ID", "price_pro_monthly"),
      "enterprise" => ENV.fetch("STRIPE_ENTERPRISE_PRICE_ID", "price_enterprise_monthly")
    }.freeze

    def show
      @tenant = current_user.tenant
    end

    def checkout
      plan = params[:plan]
      price_id = PRICE_IDS[plan]
      return redirect_to settings_billing_path, alert: "Invalid plan" unless price_id

      tenant = current_user.tenant
      session = Stripe::Checkout::Session.create(
        mode: "subscription",
        customer: tenant.stripe_customer_id.presence || nil,
        customer_email: tenant.stripe_customer_id.blank? ? current_user.email : nil,
        line_items: [{ price: price_id, quantity: 1 }],
        success_url: "#{ENV.fetch('APP_HOST', 'http://localhost:3000')}/settings/billing?upgraded=1",
        cancel_url: "#{ENV.fetch('APP_HOST', 'http://localhost:3000')}/settings/billing",
        metadata: { tenant_id: tenant.id, plan: plan }
      )

      redirect_to session.url, allow_other_host: true
    end

    def portal
      tenant = current_user.tenant
      return redirect_to settings_billing_path, alert: "No billing account" unless tenant.stripe_customer_id.present?

      session = Stripe::BillingPortal::Session.create(
        customer: tenant.stripe_customer_id,
        return_url: "#{ENV.fetch('APP_HOST', 'http://localhost:3000')}/settings/billing"
      )

      redirect_to session.url, allow_other_host: true
    end

    private

    def require_owner_or_manager
      return if current_user&.owner_or_manager?

      redirect_to root_path, alert: "Not authorized"
    end
  end
end
