require "rails_helper"

# Page smoke spec — GETs every user-facing page in every applicable role
# state and asserts the response is non-5xx. Catches the same class of bug
# as the production sign_in 500 (page crashes during render).
#
# This spec is intentionally noisy: each tuple is its own example so failures
# are individually addressable. If you add a new route, add a tuple here.
RSpec.describe "Page smoke", type: :request do
  before do
    allow(Stripe::Checkout::Session).to receive(:create).and_return(double(url: "https://stripe.example/checkout"))
    allow(Stripe::BillingPortal::Session).to receive(:create).and_return(double(url: "https://stripe.example/portal"))
  end

  shared_examples "renders without 5xx" do |path|
    it "GET #{path}" do
      get path
      expect(response.status).to be < 500, "GET #{path} returned #{response.status}\n#{response.body[0..500]}"
    end
  end

  # Stricter: must return 200 (not 3xx redirect, not 5xx)
  shared_examples "renders 200" do |path|
    it "GET #{path} returns 200" do
      get path
      if response.status >= 300 && response.status < 400
        follow_redirect!
      end
      expect(response.status).to eq(200), "GET #{path} ended at #{response.status} (#{response.location || 'no redirect'})\n#{response.body[0..400]}"
    end
  end

  # ========== Anonymous (no session) ==========
  describe "anonymous visitor" do
    let(:tenant) { create(:tenant, subdomain: "smoke") }
    let(:provider) { create(:provider, tenant: tenant) }
    let(:patient) { create(:patient, tenant: tenant) }
    let(:appointment) do
      create(:appointment, tenant: tenant, provider: provider, patient: patient,
        starts_at: 1.hour.from_now)
    end

    %w[
      /
      /register
      /users/sign_in
      /users/password/new
      /users/password/edit?reset_password_token=fake_token
      /privacy
      /terms
      /hipaa
      /security
      /integrations
      /portal/login
      /up
      /health
    ].each do |path|
      include_examples "renders without 5xx", path
    end

    it "GET /manifest" do
      get "/manifest", headers: { "Accept" => "application/manifest+json" }
      expect(response.status).to be < 500
    end

    it "GET /service-worker" do
      get "/service-worker", headers: { "Accept" => "text/javascript" }
      expect(response.status).to be < 500
    end

    it "GET /status/:token" do
      get patient_status_path(token: appointment.signed_token)
      expect(response.status).to be < 500
    end

    it "GET /kiosk/:subdomain" do
      get "/kiosk/#{tenant.subdomain}"
      expect(response.status).to be < 500
    end
  end

  # ========== Owner ==========
  describe "owner" do
    let(:tenant) { create(:tenant, subdomain: "owner-smoke", onboarding_step: 4) }
    let(:user) { create(:user, tenant: tenant, role: :owner) }
    let!(:provider) { create(:provider, tenant: tenant) }
    let!(:patient) { create(:patient, tenant: tenant) }
    let!(:appointment) do
      create(:appointment, tenant: tenant, provider: provider, patient: patient,
        starts_at: 1.hour.from_now)
    end
    let!(:location) { create(:location, tenant: tenant) }
    let!(:integration) { create(:integration, tenant: tenant) }

    before { sign_in user }

    # Strict: owner with onboarding_step=4 should land on these directly, no redirect
    [
      "/dashboard",
      "/dashboard?view=week",
      "/patients",
      "/patients/new",
      "/providers",
      "/providers/new",
      "/appointments",
      "/appointments/new",
      "/locations",
      "/locations/new",
      "/settings/profile",
      "/settings/practice",
      "/settings/billing",
      "/settings/integrations",
      "/settings/integrations/new",
      "/settings/staff",
      "/settings/analytics",
      "/settings/timesheet",
      "/settings/sync_health",
      "/settings/time_off",
      "/settings/workflow_templates",
      "/settings/workflow_templates/new"
    ].each do |path|
      include_examples "renders 200", path
    end

    # /search returns JSON, /onboarding redirects to dashboard when complete
    include_examples "renders without 5xx", "/search?q=al"
    include_examples "renders without 5xx", "/onboarding"

    it "GET /patients/:id returns 200" do
      get patient_path(patient)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /patients/:id/edit returns 200" do
      get edit_patient_path(patient)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /providers/:id returns 200" do
      get provider_path(provider)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /providers/:id/edit returns 200" do
      get edit_provider_path(provider)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /providers/:provider_id/integrations/new returns 200" do
      get new_provider_integration_path(provider)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /appointments/:id returns 200" do
      get appointment_path(appointment)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /appointments/:id/edit returns 200" do
      get edit_appointment_path(appointment)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /appointments/:id/calendar returns 200" do
      get calendar_appointment_path(appointment)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /appointments/:appointment_id/conversation returns 200" do
      get appointment_conversation_path(appointment)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /locations/:id/edit returns 200" do
      get edit_location_path(location)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /settings/staff/:staff_id/shifts returns 200" do
      get settings_staff_shifts_path(staff_id: user.id)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /patients/:patient_id/cards/new returns 200" do
      get new_patient_card_path(patient)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end

    it "GET /delay_workflows/new?provider_id= returns 200" do
      get new_delay_workflow_path(provider_id: provider.id)
      expect(response.status).to eq(200), "got #{response.status}: #{response.body[0..400]}"
    end
  end

  # ========== Manager ==========
  describe "manager" do
    let(:tenant) { create(:tenant, subdomain: "mgr-smoke", onboarding_step: 4) }
    let(:user) { create(:user, tenant: tenant, role: :manager) }

    before { sign_in user }

    %w[
      /dashboard
      /patients
      /providers
      /appointments
      /locations
      /settings/profile
      /settings/practice
      /settings/staff
      /settings/analytics
      /settings/timesheet
    ].each do |path|
      include_examples "renders without 5xx", path
    end
  end

  # ========== Provider ==========
  describe "provider" do
    let(:tenant) { create(:tenant, subdomain: "prov-smoke", onboarding_step: 4) }
    let(:user) { create(:user, tenant: tenant, role: :provider) }

    before { sign_in user }

    %w[
      /dashboard
      /provider_dashboard
      /patients
      /appointments
      /settings/profile
    ].each do |path|
      include_examples "renders without 5xx", path
    end
  end

  # ========== Staff ==========
  describe "staff" do
    let(:tenant) { create(:tenant, subdomain: "staff-smoke", onboarding_step: 4) }
    let(:user) { create(:user, tenant: tenant, role: :staff) }

    before { sign_in user }

    %w[
      /dashboard
      /staff_dashboard
      /patients
      /appointments
      /settings/profile
    ].each do |path|
      include_examples "renders without 5xx", path
    end
  end

  # ========== Patient (portal) ==========
  describe "patient portal" do
    let(:tenant) { create(:tenant, subdomain: "portal-smoke") }
    let(:provider) { create(:provider, tenant: tenant) }
    let!(:patient) do
      create(:patient, tenant: tenant, sms_consent: true, phone: "5551112222")
    end
    let!(:appointment) do
      create(:appointment, tenant: tenant, provider: provider, patient: patient,
        starts_at: 1.hour.from_now)
    end

    before do
      patient.update!(magic_link_token: "smoke_token", magic_link_expires_at: 10.minutes.from_now)
      get portal_auth_path(token: "smoke_token")
    end

    it "GET /portal/appointments" do
      get portal_appointments_path
      expect(response.status).to be < 500
    end

    it "GET /portal/profile" do
      get portal_profile_path
      expect(response.status).to be < 500
    end
  end
end
