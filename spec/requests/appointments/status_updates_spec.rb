require "rails_helper"

RSpec.describe "Appointments::StatusUpdates", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :checked_in) }

  before { sign_in user }

  describe "PATCH /appointments/:id/status" do
    it "transitions to the requested status" do
      patch status_appointment_path(appointment),
        params: { status: "in_room" },
        as: :turbo_stream

      expect(appointment.reload.status).to eq("in_room")
    end

    it "records delay_minutes for running_late" do
      patch status_appointment_path(appointment),
        params: { status: "running_late", delay_minutes: 15 },
        as: :turbo_stream

      expect(appointment.reload.delay_minutes).to eq(15)
      expect(StatusEvent.last.delay_minutes).to eq(15)
    end

    it "records a note" do
      patch status_appointment_path(appointment),
        params: { status: "running_late", delay_minutes: 10, note: "Provider stuck in procedure" },
        as: :turbo_stream

      expect(StatusEvent.last.note).to eq("Provider stuck in procedure")
    end

    it "returns turbo stream response" do
      patch status_appointment_path(appointment),
        params: { status: "in_room" },
        as: :turbo_stream

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "rejects invalid transitions" do
      appointment.update!(status: :complete)
      patch status_appointment_path(appointment),
        params: { status: "checked_in" },
        as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
