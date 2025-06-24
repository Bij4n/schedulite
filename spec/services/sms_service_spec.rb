require "rails_helper"

RSpec.describe SmsService do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex", phone: "5551234567") }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: Time.current.change(hour: 14, min: 30)) }

  let(:twilio_client) { instance_double(Twilio::REST::Client) }
  let(:messages) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList) }
  let(:message_response) { double(sid: "SM1234567890abcdef") }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive_message_chain(:messages, :create).and_return(message_response)
    allow(Rails.application.credentials).to receive(:dig).with(:twilio, :account_sid).and_return("AC_test")
    allow(Rails.application.credentials).to receive(:dig).with(:twilio, :auth_token).and_return("token_test")
    allow(Rails.application.credentials).to receive(:dig).with(:twilio, :phone_number).and_return("+15550001234")
  end

  describe ".call" do
    it "sends an SMS via Twilio" do
      expect(twilio_client).to receive_message_chain(:messages, :create).with(
        hash_including(to: "+15551234567", from: "+15550001234")
      ).and_return(message_response)

      described_class.call(
        patient: patient,
        appointment: appointment,
        template: :check_in_confirmation
      )
    end

    it "creates an SmsMessage record" do
      expect {
        described_class.call(patient: patient, appointment: appointment, template: :check_in_confirmation)
      }.to change(SmsMessage, :count).by(1)

      msg = SmsMessage.last
      expect(msg.direction).to eq("outbound")
      expect(msg.patient).to eq(patient)
      expect(msg.appointment).to eq(appointment)
      expect(msg.twilio_sid).to eq("SM1234567890abcdef")
      expect(msg.body).to include("Alex")
    end

    it "renders the correct template" do
      described_class.call(patient: patient, appointment: appointment, template: :delay_notice, delay_minutes: 20)

      msg = SmsMessage.last
      expect(msg.body).to include("20")
      expect(msg.body).to include("running")
    end

    it "formats phone number with country code" do
      expect(twilio_client).to receive_message_chain(:messages, :create).with(
        hash_including(to: "+15551234567")
      ).and_return(message_response)

      described_class.call(patient: patient, appointment: appointment, template: :check_in_confirmation)
    end

    context "when Twilio credentials are missing" do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:twilio, :account_sid).and_return(nil)
        allow(Rails.application.credentials).to receive(:dig).with(:twilio, :auth_token).and_return(nil)
        allow(Rails.application.credentials).to receive(:dig).with(:twilio, :phone_number).and_return(nil)
      end

      it "does not raise and logs a warning" do
        expect(Rails.logger).to receive(:warn).with(/Twilio not configured/)

        expect {
          described_class.call(patient: patient, appointment: appointment, template: :check_in_confirmation)
        }.not_to raise_error
      end

      it "does not create an SmsMessage record" do
        allow(Rails.logger).to receive(:warn)

        expect {
          described_class.call(patient: patient, appointment: appointment, template: :check_in_confirmation)
        }.not_to change(SmsMessage, :count)
      end
    end

    context "when Twilio API call fails" do
      before do
        allow(twilio_client).to receive_message_chain(:messages, :create).and_raise(Twilio::REST::TwilioError.new("API error"))
      end

      it "does not raise and logs the error" do
        expect(Rails.logger).to receive(:error).with(/SMS delivery failed/)

        expect {
          described_class.call(patient: patient, appointment: appointment, template: :check_in_confirmation)
        }.not_to raise_error
      end
    end
  end
end
