require "rails_helper"

RSpec.describe "Appointments::Conversations", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex") }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient) }

  before { sign_in user }

  describe "GET /appointments/:id/conversation" do
    it "returns success" do
      get appointment_conversation_path(appointment)
      expect(response).to have_http_status(:ok)
    end

    it "shows SMS messages for the appointment" do
      create(:sms_message, appointment: appointment, patient: patient, direction: :outbound, body: "Checked in successfully!")
      create(:sms_message, appointment: appointment, patient: patient, direction: :inbound, body: "Thanks!")

      get appointment_conversation_path(appointment)
      expect(response.body).to include("Checked in successfully!")
      expect(response.body).to include("Thanks!")
    end

    it "shows patient name" do
      get appointment_conversation_path(appointment)
      expect(response.body).to include("Alex")
    end
  end
end
