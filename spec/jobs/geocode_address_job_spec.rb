require "rails_helper"

RSpec.describe GeocodeAddressJob, type: :job do
  let(:tenant) { create(:tenant) }

  describe "#perform" do
    it "geocodes a patient address" do
      patient = create(:patient, tenant: tenant, address: "123 Main St, Springfield, IL")

      allow(GeocodingService).to receive(:geocode)
        .with(patient.full_address)
        .and_return(latitude: 39.78, longitude: -89.65)

      described_class.perform_now("Patient", patient.id)

      patient.reload
      expect(patient.latitude).to be_within(0.01).of(39.78)
      expect(patient.longitude).to be_within(0.01).of(-89.65)
    end

    it "does nothing for a non-existent record" do
      expect {
        described_class.perform_now("Patient", 999_999)
      }.not_to raise_error
    end

    it "does nothing when geocoding returns nil" do
      patient = create(:patient, tenant: tenant, address: "nowhere")

      allow(GeocodingService).to receive(:geocode).and_return(nil)

      described_class.perform_now("Patient", patient.id)

      patient.reload
      expect(patient.latitude).to be_nil
    end
  end
end
