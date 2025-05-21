require "rails_helper"

RSpec.describe AppointmentReminderJob, type: :job do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex", sms_consent: true) }

  let(:twilio_client) { instance_double(Twilio::REST::Client) }
  let(:messages) { double("messages") }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive(:messages).and_return(messages)
    allow(messages).to receive(:create).and_return(double(sid: "SM_reminder"))
    allow(Rails.application.credentials).to receive(:dig).and_return("test")
  end

  describe "#perform" do
    context "24-hour reminders" do
      it "sends SMS for appointments 24 hours away" do
        appt = create(:appointment, tenant: tenant, provider: provider, patient: patient,
          starts_at: 24.hours.from_now, status: :scheduled)

        expect(messages).to receive(:create)
        described_class.perform_now(hours_before: 24)
      end

      it "does not send for appointments not in the window" do
        create(:appointment, tenant: tenant, provider: provider, patient: patient,
          starts_at: 48.hours.from_now, status: :scheduled)

        expect(messages).not_to receive(:create)
        described_class.perform_now(hours_before: 24)
      end

      it "does not send if patient opted out" do
        patient.update!(sms_consent: false)
        create(:appointment, tenant: tenant, provider: provider, patient: patient,
          starts_at: 24.hours.from_now, status: :scheduled)

        expect(messages).not_to receive(:create)
        described_class.perform_now(hours_before: 24)
      end

      it "does not send for canceled appointments" do
        create(:appointment, tenant: tenant, provider: provider, patient: patient,
          starts_at: 24.hours.from_now, status: :canceled)

        expect(messages).not_to receive(:create)
        described_class.perform_now(hours_before: 24)
      end
    end
  end
end
