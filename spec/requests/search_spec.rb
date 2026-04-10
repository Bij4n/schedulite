require "rails_helper"

RSpec.describe "Search", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, role: :owner) }

  before { sign_in user }

  describe "GET /search" do
    it "returns empty results for queries shorter than 2 chars" do
      get "/search", params: { q: "a" }, headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["results"]).to eq([])
    end

    it "finds patients by partial name" do
      patient = create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera")

      get "/search", params: { q: "alex" }, headers: { "Accept" => "application/json" }

      results = JSON.parse(response.body)["results"]
      expect(results.length).to be >= 1
      expect(results.first["type"]).to eq("patient")
      expect(results.first["url"]).to eq(patient_path(patient))
    end

    it "finds patients by phone digits" do
      patient = create(:patient, tenant: tenant, phone: "5551234567")

      get "/search", params: { q: "5551234567" }, headers: { "Accept" => "application/json" }

      results = JSON.parse(response.body)["results"]
      expect(results.first["url"]).to eq(patient_path(patient))
    end

    it "returns JSON content type" do
      get "/search", params: { q: "ax" }, headers: { "Accept" => "application/json" }
      expect(response.content_type).to include("application/json")
    end
  end
end
