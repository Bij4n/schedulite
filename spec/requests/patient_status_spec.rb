require "rails_helper"

RSpec.describe "PatientStatus", type: :request do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant, first_name: "Sarah", last_name: "Lee") }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera") }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: Time.current.change(hour: 14, min: 30), status: :checked_in) }

  describe "GET /status/:signed_token" do
    it "renders the status page" do
      get patient_status_path(token: appointment.signed_token)
      expect(response).to have_http_status(:ok)
    end

    it "shows appointment info" do
      get patient_status_path(token: appointment.signed_token)
      expect(response.body).to include("Alex")
      expect(response.body).to include("2:30 PM")
      expect(response.body).to include("Dr. Lee")
    end

    it "shows current status" do
      get patient_status_path(token: appointment.signed_token)
      expect(response.body).to include("Checked In")
    end

    it "does not require authentication" do
      get patient_status_path(token: appointment.signed_token)
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for invalid token" do
      get patient_status_path(token: "invalid_token_xyz")
      expect(response).to have_http_status(:not_found)
    end

    it "shows delay info when running late" do
      appointment.update!(status: :running_late, delay_minutes: 20)
      get patient_status_path(token: appointment.signed_token)
      expect(response.body).to include("20")
    end
  end
end
