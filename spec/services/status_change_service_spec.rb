require "rails_helper"

RSpec.describe StatusChangeService do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :scheduled) }

  before do
    allow(SmsService).to receive(:call)
    allow(GiftCardIssuanceService).to receive(:call)
  end

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

    context "SMS notifications" do
      before do
        allow(SmsService).to receive(:call)
      end

      it "sends check_in_confirmation SMS when checking in" do
        expect(SmsService).to receive(:call).with(hash_including(template: :check_in_confirmation))
        described_class.call(appointment: appointment, user: user, new_status: "checked_in")
      end

      it "sends delay_notice SMS when running late" do
        appointment.update!(status: :checked_in)
        expect(SmsService).to receive(:call).with(hash_including(template: :delay_notice, delay_minutes: 15))
        described_class.call(appointment: appointment, user: user, new_status: "running_late", delay_minutes: 15)
      end

      it "sends youre_next SMS when moving to in_room after running_late" do
        appointment.update!(status: :running_late)
        expect(SmsService).to receive(:call).with(hash_including(template: :youre_next))
        described_class.call(appointment: appointment, user: user, new_status: "in_room")
      end

      it "does not send SMS if patient opted out" do
        patient.update!(sms_consent: false)
        expect(SmsService).not_to receive(:call)
        described_class.call(appointment: appointment, user: user, new_status: "checked_in")
      end
    end

    context "gift card issuance" do
      before do
        allow(SmsService).to receive(:call)
        allow(GiftCardIssuanceService).to receive(:call)
      end

      it "triggers gift card check when running late" do
        appointment.update!(status: :checked_in)
        expect(GiftCardIssuanceService).to receive(:call).with(appointment: appointment)
        described_class.call(appointment: appointment, user: user, new_status: "running_late", delay_minutes: 30)
      end

      it "does not trigger gift card for non-delay transitions" do
        expect(GiftCardIssuanceService).not_to receive(:call)
        described_class.call(appointment: appointment, user: user, new_status: "checked_in")
      end
    end
  end
end
