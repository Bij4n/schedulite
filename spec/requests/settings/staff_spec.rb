require "rails_helper"

RSpec.describe "Settings::Staff", type: :request do
  let(:tenant) { create(:tenant) }
  let(:owner) { create(:user, tenant: tenant, role: :owner) }
  let(:staff_user) { create(:user, tenant: tenant, role: :staff) }

  describe "GET /settings/staff" do
    it "lists staff members for owner" do
      sign_in owner
      create(:user, tenant: tenant, first_name: "Jane", last_name: "Doe", role: :staff)

      get settings_staff_index_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jane Doe")
    end

    it "denies access to front_desk role" do
      sign_in staff_user
      get settings_staff_index_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /settings/staff" do
    before { sign_in owner }

    it "creates a new staff member" do
      expect {
        post settings_staff_index_path, params: {
          user: { first_name: "New", last_name: "Staff", email: "new@example.com", role: "staff" }
        }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(settings_staff_index_path)
    end

    it "assigns the correct role" do
      post settings_staff_index_path, params: {
        user: { first_name: "Dr", last_name: "Provider", email: "dr@example.com", role: "provider" }
      }

      expect(User.last.role).to eq("provider")
    end

    it "assigns to current tenant" do
      post settings_staff_index_path, params: {
        user: { first_name: "A", last_name: "B", email: "ab@example.com", role: "manager" }
      }

      expect(User.last.tenant).to eq(tenant)
    end
  end

  describe "PATCH /settings/staff/:id" do
    before { sign_in owner }

    it "updates staff role" do
      staff = create(:user, tenant: tenant, role: :staff)
      patch settings_staff_path(staff), params: { user: { role: "manager" } }

      expect(staff.reload.role).to eq("manager")
      expect(response).to redirect_to(settings_staff_index_path)
    end
  end

  describe "DELETE /settings/staff/:id" do
    before { sign_in owner }

    it "deactivates a staff member" do
      staff = create(:user, tenant: tenant, role: :staff)
      delete settings_staff_path(staff)

      expect(User.exists?(staff.id)).to eq(false)
      expect(response).to redirect_to(settings_staff_index_path)
    end

    it "prevents deleting yourself" do
      delete settings_staff_path(owner)
      expect(User.exists?(owner.id)).to eq(true)
    end
  end
end
