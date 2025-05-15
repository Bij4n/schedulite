require "rails_helper"

RSpec.describe "Appointments::CheckIns", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :scheduled) }

  before { sign_in user }

  describe "PATCH /appointments/:id/check_in" do
    it "transitions to checked_in" do
      patch check_in_appointment_path(appointment), as: :turbo_stream
      expect(appointment.reload.status).to eq("checked_in")
    end

    it "returns a turbo stream response" do
      patch check_in_appointment_path(appointment), as: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "creates a StatusEvent" do
      expect {
        patch check_in_appointment_path(appointment), as: :turbo_stream
      }.to change(StatusEvent, :count).by(1)
    end

    it "rejects invalid transitions" do
      appointment.update!(status: :complete)
      patch check_in_appointment_path(appointment), as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context "when not authenticated" do
      before { sign_out user }

      it "redirects to sign in" do
        patch check_in_appointment_path(appointment)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
