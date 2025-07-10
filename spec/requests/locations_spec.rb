require "rails_helper"

RSpec.describe "Locations", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, role: :owner) }

  before { sign_in user }

  describe "GET /locations" do
    it "lists locations" do
      create(:location, tenant: tenant, name: "Downtown")
      get locations_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Downtown")
    end
  end

  describe "POST /locations" do
    it "creates a new location" do
      expect {
        post locations_path, params: { location: { name: "Uptown", address: "1 Pine St" } }
      }.to change(Location, :count).by(1)

      expect(response).to redirect_to(locations_path)
    end
  end

  describe "PATCH /locations/:id" do
    it "updates a location" do
      location = create(:location, tenant: tenant, name: "Old Name")
      patch location_path(location), params: { location: { name: "New Name" } }
      expect(location.reload.name).to eq("New Name")
    end
  end

  describe "DELETE /locations/:id" do
    it "removes a location" do
      location = create(:location, tenant: tenant)
      expect {
        delete location_path(location)
      }.to change(Location, :count).by(-1)
    end
  end

  describe "permissions" do
    let(:staff_user) { create(:user, tenant: tenant, role: :staff) }

    it "blocks staff from accessing locations" do
      sign_in staff_user
      get locations_path
      expect(response).to redirect_to(root_path)
    end
  end
end
