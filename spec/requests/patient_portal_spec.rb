require "rails_helper"

RSpec.describe "Patient portal", type: :request do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let!(:patient) do
    create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera",
      phone: "5551234567", sms_consent: true)
  end

  describe "GET /portal/login" do
    it "shows the login form" do
      get portal_login_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign in")
    end
  end

  describe "POST /portal/request_link" do
    before { allow(SmsService).to receive(:call) }

    it "generates a magic link token for a known phone number" do
      expect {
        post portal_request_link_path, params: { phone: "5551234567" }
      }.to change { patient.reload.magic_link_token }
    end

    it "sets an expiration on the token" do
      post portal_request_link_path, params: { phone: "5551234567" }
      expect(patient.reload.magic_link_expires_at).to be_within(2.minutes).of(15.minutes.from_now)
    end

    it "redirects to a confirmation page even when phone is unknown" do
      post portal_request_link_path, params: { phone: "5559999999" }
      expect(response).to redirect_to(portal_login_path)
    end
  end

  describe "GET /portal/auth/:token" do
    it "logs the patient in with a valid token" do
      patient.update!(magic_link_token: "valid_token", magic_link_expires_at: 10.minutes.from_now)
      get portal_auth_path(token: "valid_token")
      expect(response).to redirect_to(portal_appointments_path)
    end

    it "rejects an expired token" do
      patient.update!(magic_link_token: "expired_token", magic_link_expires_at: 1.minute.ago)
      get portal_auth_path(token: "expired_token")
      expect(response).to redirect_to(portal_login_path)
    end

    it "rejects an unknown token" do
      get portal_auth_path(token: "nonexistent")
      expect(response).to redirect_to(portal_login_path)
    end
  end

  describe "GET /portal/appointments" do
    before { sign_in_patient(patient) }

    it "shows the patient's appointments" do
      create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: 2.days.from_now)
      get portal_appointments_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects to login when not signed in" do
      reset!
      get portal_appointments_path
      expect(response).to redirect_to(portal_login_path)
    end
  end

  def sign_in_patient(patient)
    patient.update!(magic_link_token: "test_token", magic_link_expires_at: 10.minutes.from_now)
    get portal_auth_path(token: "test_token")
  end
end
