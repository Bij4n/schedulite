require "rails_helper"

RSpec.describe "API::V1::Appointments", type: :request do
  let(:tenant) { create(:tenant) }
  let(:api_key) { APIKey.create!(tenant: tenant, name: "Test") }
  let(:headers) { { "X-API-Key" => api_key.raw_key, "Accept" => "application/json" } }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera") }

  describe "GET /api/v1/appointments" do
    it "returns today's appointments" do
      create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: Time.current.change(hour: 14))

      get "/api/v1/appointments", headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["data"].length).to eq(1)
      expect(json["data"][0]["patient_name"]).to eq("Alex R.")
    end

    it "returns 401 without API key" do
      get "/api/v1/appointments"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with invalid API key" do
      get "/api/v1/appointments", headers: { "X-API-Key" => "bad_key" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/appointments" do
    let(:params) do
      {
        appointment: {
          patient_first_name: "Jordan",
          patient_last_name: "Kim",
          patient_phone: "5559876543",
          provider_id: provider.id,
          starts_at: Time.current.change(hour: 15).iso8601
        }
      }
    end

    it "creates an appointment" do
      expect {
        post "/api/v1/appointments", params: params.to_json, headers: headers.merge("Content-Type" => "application/json")
      }.to change(Appointment, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "creates a patient if needed" do
      expect {
        post "/api/v1/appointments", params: params.to_json, headers: headers.merge("Content-Type" => "application/json")
      }.to change(Patient, :count).by(1)
    end
  end

  describe "PATCH /api/v1/appointments/:id" do
    let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient) }

    it "updates status" do
      patch "/api/v1/appointments/#{appointment.id}",
        params: { status: "checked_in" }.to_json,
        headers: headers.merge("Content-Type" => "application/json")

      expect(response).to have_http_status(:ok)
      expect(appointment.reload.status).to eq("checked_in")
    end

    it "rejects invalid transitions" do
      appointment.update!(status: :complete)
      patch "/api/v1/appointments/#{appointment.id}",
        params: { status: "checked_in" }.to_json,
        headers: headers.merge("Content-Type" => "application/json")

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
