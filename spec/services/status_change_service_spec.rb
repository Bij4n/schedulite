require "rails_helper"

RSpec.describe StatusChangeService do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :scheduled) }

  describe ".call" do
    context "with a valid transition" do
      it "updates the appointment status" do
        result = described_class.call(appointment: appointment, user: user, new_status: "checked_in")

        expect(result).to be_success
        expect(appointment.reload.status).to eq("checked_in")
      end

      it "creates a StatusEvent" do
        expect {
          described_class.call(appointment: appointment, user: user, new_status: "checked_in")
        }.to change(StatusEvent, :count).by(1)

        event = StatusEvent.last
        expect(event.from_status).to eq("scheduled")
        expect(event.to_status).to eq("checked_in")
        expect(event.user).to eq(user)
        expect(event.appointment).to eq(appointment)
      end

      it "records delay_minutes when provided" do
        appointment.update!(status: :checked_in)
        described_class.call(
          appointment: appointment, user: user,
          new_status: "running_late", delay_minutes: 15
        )

        event = StatusEvent.last
        expect(event.delay_minutes).to eq(15)
      end

      it "records a note when provided" do
        described_class.call(
          appointment: appointment, user: user,
          new_status: "checked_in", note: "Arrived early"
        )

        expect(StatusEvent.last.note).to eq("Arrived early")
      end

      it "updates appointment delay_minutes" do
        appointment.update!(status: :checked_in)
        described_class.call(
          appointment: appointment, user: user,
          new_status: "running_late", delay_minutes: 20
        )

        expect(appointment.reload.delay_minutes).to eq(20)
      end
    end

    context "with an invalid transition" do
      it "returns failure for complete -> checked_in" do
        appointment.update!(status: :complete)
        result = described_class.call(appointment: appointment, user: user, new_status: "checked_in")

        expect(result).not_to be_success
        expect(result.error).to be_present
        expect(appointment.reload.status).to eq("complete")
      end

      it "does not create a StatusEvent" do
        appointment.update!(status: :complete)
        expect {
          described_class.call(appointment: appointment, user: user, new_status: "checked_in")
        }.not_to change(StatusEvent, :count)
      end
    end

    context "transition rules" do
      it "allows scheduled -> checked_in" do
        result = described_class.call(appointment: appointment, user: user, new_status: "checked_in")
        expect(result).to be_success
      end

      it "allows checked_in -> in_room" do
        appointment.update!(status: :checked_in)
        result = described_class.call(appointment: appointment, user: user, new_status: "in_room")
        expect(result).to be_success
      end

      it "allows any status -> running_late" do
        result = described_class.call(appointment: appointment, user: user, new_status: "running_late")
        expect(result).to be_success
      end

      it "allows any active status -> complete" do
        appointment.update!(status: :in_room)
        result = described_class.call(appointment: appointment, user: user, new_status: "complete")
        expect(result).to be_success
      end

      it "allows scheduled -> no_show" do
        result = described_class.call(appointment: appointment, user: user, new_status: "no_show")
        expect(result).to be_success
      end

      it "allows scheduled -> canceled" do
        result = described_class.call(appointment: appointment, user: user, new_status: "canceled")
        expect(result).to be_success
      end
    end
  end
end
