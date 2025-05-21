require "rails_helper"

RSpec.describe "Webhooks::Twilio", type: :request do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant, phone: "5551234567") }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient) }

  describe "POST /webhooks/twilio" do
    let(:params) do
      {
        From: "+15551234567",
        Body: "OK thanks!",
        MessageSid: "SM_inbound_123"
      }
    end

    it "creates an inbound SmsMessage" do
      appointment # ensure it exists

      expect {
        post webhooks_twilio_path, params: params
      }.to change(SmsMessage, :count).by(1)

      msg = SmsMessage.last
      expect(msg.direction).to eq("inbound")
      expect(msg.body).to eq("OK thanks!")
      expect(msg.twilio_sid).to eq("SM_inbound_123")
      expect(msg.patient).to eq(patient)
    end

    it "returns 200 with TwiML" do
      appointment
      post webhooks_twilio_path, params: params
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/xml")
    end

    it "returns 200 even if patient not found" do
      post webhooks_twilio_path, params: params.merge(From: "+15559999999")
      expect(response).to have_http_status(:ok)
    end

    context "when patient replies STOP" do
      it "opts the patient out of SMS" do
        patient # ensure exists
        post webhooks_twilio_path, params: params.merge(Body: "STOP")

        expect(patient.reload.sms_consent).to eq(false)
        expect(patient.sms_opted_out_at).to be_present
      end
    end

    context "when patient replies START" do
      it "opts the patient back in" do
        patient.update!(sms_consent: false, sms_opted_out_at: 1.day.ago)
        post webhooks_twilio_path, params: params.merge(Body: "START")

        expect(patient.reload.sms_consent).to eq(true)
        expect(patient.sms_opted_out_at).to be_nil
      end
    end
  end
end
