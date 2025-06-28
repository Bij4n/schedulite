require "rails_helper"

RSpec.describe "Registration and Kiosk", type: :system do
  describe "registration" do
    it "creates a new practice account" do
      visit register_path
      expect(page).to have_content("Start your free trial")

      fill_in "Practice Name", with: "Test Clinic"
      fill_in "Subdomain", with: "testclinic"
      fill_in "First name", with: "Dr."
      fill_in "Last name", with: "Test"
      fill_in "Email", with: "dr.test@example.com"
      fill_in "Password", with: "password123!"
      click_button "Create Your Practice"

      expect(page).to have_current_path(dashboard_index_path)
    end
  end

  describe "kiosk check-in" do
    let(:tenant) { create(:tenant, subdomain: "sunrise") }
    let(:provider) { create(:provider, tenant: tenant) }
    let!(:patient) { create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera", phone: "5551234567") }
    let!(:appointment) do
      create(:appointment, tenant: tenant, provider: provider, patient: patient,
        starts_at: Time.current.change(hour: 14, min: 30), status: :scheduled)
    end

    before do
      allow(SmsService).to receive(:call)
    end

    it "shows the kiosk check-in form" do
      visit "/kiosk/sunrise"
      expect(page).to have_content("Check In")
    end

    it "checks in a patient by phone number" do
      visit "/kiosk/sunrise"
      fill_in "Phone", with: "5551234567"
      click_button "Check In"

      expect(page).to have_content("confirmed")
    end
  end

  describe "settings navigation" do
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, tenant: tenant, role: :owner) }

    before { sign_in user }

    it "loads the profile settings page" do
      visit settings_profile_path
      expect(page).to have_http_status(:ok)
    end

    it "loads the practice settings page" do
      visit settings_practice_path
      expect(page).to have_http_status(:ok)
    end

    it "loads the integrations settings page" do
      visit settings_integrations_path
      expect(page).to have_http_status(:ok)
    end

    it "loads the analytics page" do
      visit settings_analytics_path
      expect(page).to have_http_status(:ok)
    end
  end
end
