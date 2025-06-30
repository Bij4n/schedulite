require "rails_helper"

RSpec.describe "Onboarding", type: :request do
  let(:tenant) { create(:tenant, onboarding_step: 0) }
  let(:user) { create(:user, tenant: tenant, role: :owner) }

  before { sign_in user }

  describe "GET /onboarding" do
    it "shows the current onboarding step" do
      get onboarding_index_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Practice Info")
    end

    it "redirects to dashboard if onboarding is complete" do
      tenant.update!(onboarding_step: 4)
      get onboarding_index_path
      expect(response).to redirect_to(dashboard_index_path)
    end
  end

  describe "PATCH /onboarding" do
    it "advances to the next step" do
      patch onboarding_index_path, params: { tenant: { address: "123 Main St" } }
      expect(tenant.reload.onboarding_step).to eq(1)
      expect(response).to redirect_to(onboarding_index_path)
    end
  end

  describe "POST /onboarding/skip" do
    it "skips to the next step" do
      post skip_onboarding_index_path
      expect(tenant.reload.onboarding_step).to eq(1)
      expect(response).to redirect_to(onboarding_index_path)
    end

    it "redirects to dashboard when skipping the last step" do
      tenant.update!(onboarding_step: 3)
      post skip_onboarding_index_path
      expect(tenant.reload.onboarding_step).to eq(4)
      expect(response).to redirect_to(dashboard_index_path)
    end
  end

  describe "dashboard redirect" do
    it "redirects new tenants to onboarding" do
      get dashboard_index_path
      expect(response).to redirect_to(onboarding_index_path)
    end

    it "does not redirect completed tenants" do
      tenant.update!(onboarding_step: 4)
      get dashboard_index_path
      expect(response).to have_http_status(:ok)
    end
  end
end
