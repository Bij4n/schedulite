require "rails_helper"

RSpec.describe "Settings::Analytics", type: :request do
  let(:tenant) { create(:tenant) }
  let(:owner) { create(:user, tenant: tenant, role: :owner) }
  let(:front_desk) { create(:user, tenant: tenant, role: :front_desk) }
  let(:provider_model) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }

  describe "GET /settings/analytics" do
    before { sign_in owner }

    it "returns success" do
      get settings_analytics_path
      expect(response).to have_http_status(:ok)
    end

    it "shows summary stats" do
      create(:appointment, tenant: tenant, provider: provider_model, patient: patient, status: :complete, starts_at: Time.current.change(hour: 9))
      get settings_analytics_path
      expect(response.body).to include("1") # total count
    end
  end

  describe "GET /settings/analytics/export.csv" do
    before { sign_in owner }

    it "returns CSV download" do
      create(:appointment, tenant: tenant, provider: provider_model, patient: patient, starts_at: 1.day.ago)
      get export_settings_analytics_path(format: :csv)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end

    it "denies front_desk" do
      sign_in front_desk
      get export_settings_analytics_path(format: :csv)
      expect(response).to redirect_to(root_path)
    end
  end
end
