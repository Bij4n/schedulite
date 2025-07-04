require "rails_helper"

RSpec.describe "Stripe Webhooks", type: :request do
  let(:tenant) { create(:tenant, stripe_customer_id: "cus_test") }

  before do
    allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
  end

  describe "checkout.session.completed" do
    let(:event) do
      double(
        type: "checkout.session.completed",
        data: double(object: {
          "customer" => "cus_test",
          "subscription" => "sub_new123",
          "metadata" => { "tenant_id" => tenant.id.to_s, "plan" => "pro" }
        })
      )
    end

    it "upgrades the tenant plan" do
      post webhooks_stripe_path, headers: { "HTTP_STRIPE_SIGNATURE" => "sig" }

      expect(response).to have_http_status(:ok)
      tenant.reload
      expect(tenant.plan).to eq("pro")
      expect(tenant.stripe_subscription_id).to eq("sub_new123")
    end
  end

  describe "customer.subscription.deleted" do
    let(:event) do
      double(
        type: "customer.subscription.deleted",
        data: double(object: {
          "customer" => "cus_test",
          "id" => "sub_canceled"
        })
      )
    end

    before { tenant.update!(plan: "pro", stripe_subscription_id: "sub_canceled") }

    it "downgrades to free plan" do
      post webhooks_stripe_path, headers: { "HTTP_STRIPE_SIGNATURE" => "sig" }

      expect(response).to have_http_status(:ok)
      tenant.reload
      expect(tenant.plan).to eq("free")
      expect(tenant.stripe_subscription_id).to be_nil
    end
  end
end
