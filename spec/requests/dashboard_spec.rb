require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  before { sign_in user }

  describe "GET /" do
    it "returns success" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "shows today's appointments" do
      provider = create(:provider, tenant: tenant)
      patient = create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera")
      create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: Time.current.change(hour: 14, min: 30))

      get root_path
      expect(response.body).to include("Alex R.")
      expect(response.body).to include("2:30 PM")
    end

    it "does not show yesterday's appointments" do
      provider = create(:provider, tenant: tenant)
      patient = create(:patient, tenant: tenant, first_name: "Yesterday", last_name: "Patient")
      create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: 1.day.ago)

      get root_path
      expect(response.body).not_to include("Yesterday P.")
    end

    it "shows empty state when no appointments" do
      get root_path
      expect(response.body).to include("No appointments today")
    end
  end
end
