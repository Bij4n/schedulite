require "rails_helper"

RSpec.describe "Billing", type: :request do
  let(:tenant) { create(:tenant, plan: "free") }
  let(:user) { create(:user, tenant: tenant, role: :owner) }

  before do
    sign_in user
    allow(Stripe::Checkout::Session).to receive(:create).and_return(
      double(url: "https://checkout.stripe.com/test_session")
    )
  end

  describe "GET /settings/billing" do
    it "shows the billing page" do
      get settings_billing_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Free")
    end
  end

  describe "POST /settings/billing/checkout" do
    it "creates a Stripe Checkout session for Pro plan" do
      post checkout_settings_billing_path, params: { plan: "pro" }
      expect(response).to redirect_to("https://checkout.stripe.com/test_session")
    end
  end

  describe "role permissions" do
    it "blocks staff from viewing billing" do
      staff = create(:user, tenant: tenant, role: :staff)
      sign_in staff

      get settings_billing_path
      expect(response).to redirect_to(root_path)
    end

    it "blocks providers from viewing billing" do
      provider = create(:user, tenant: tenant, role: :provider)
      sign_in provider

      get settings_billing_path
      expect(response).to redirect_to(root_path)
    end

    it "allows managers to view billing" do
      manager = create(:user, tenant: tenant, role: :manager)
      sign_in manager

      get settings_billing_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /settings/billing/portal" do
    before do
      tenant.update!(stripe_customer_id: "cus_test123")
      allow(Stripe::BillingPortal::Session).to receive(:create).and_return(
        double(url: "https://billing.stripe.com/portal")
      )
    end

    it "redirects to Stripe billing portal" do
      post portal_settings_billing_path
      expect(response).to redirect_to("https://billing.stripe.com/portal")
    end
  end
end
