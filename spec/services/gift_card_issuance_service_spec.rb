require "rails_helper"

RSpec.describe GiftCardIssuanceService do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :running_late, delay_minutes: 30) }
  let!(:settings) { create(:gift_card_settings, tenant: tenant, delay_threshold_minutes: 20, amount_cents: 1000, merchant_name: "Blue Bottle Coffee") }

  let(:square_client) { instance_double(SquareClient) }

  before do
    allow(SquareClient).to receive(:new).and_return(square_client)
    allow(square_client).to receive(:create_gift_card).and_return(
      { gift_card: { gan: "7783320006753271", id: "gftc_abc123" } }
    )
    allow(square_client).to receive(:activate_gift_card).and_return({ success: true })

    allow(Rails.application.credentials).to receive(:dig).with(:square, :access_token).and_return("sq_test")
    allow(Rails.application.credentials).to receive(:dig).with(:square, :location_id).and_return("loc_test")
  end

  describe ".call" do
    it "creates a GiftCard record" do
      expect {
        described_class.call(appointment: appointment)
      }.to change(GiftCard, :count).by(1)

      card = GiftCard.last
      expect(card.amount_cents).to eq(1000)
      expect(card.merchant_name).to eq("Blue Bottle Coffee")
      expect(card.square_gan).to eq("7783320006753271")
      expect(card.appointment).to eq(appointment)
    end

    it "does not issue if delay is below threshold" do
      appointment.update!(delay_minutes: 10)
      expect {
        described_class.call(appointment: appointment)
      }.not_to change(GiftCard, :count)
    end

    it "does not double-issue for the same appointment" do
      described_class.call(appointment: appointment)
      expect {
        described_class.call(appointment: appointment)
      }.not_to change(GiftCard, :count)
    end

    it "does not issue if settings are not configured" do
      settings.destroy
      expect {
        described_class.call(appointment: appointment)
      }.not_to change(GiftCard, :count)
    end

    it "calls Square API without any PHI" do
      expect(square_client).to receive(:create_gift_card).with(
        location_id: "loc_test",
        idempotency_key: "appointment_#{appointment.id}"
      )

      described_class.call(appointment: appointment)
    end
  end
end
