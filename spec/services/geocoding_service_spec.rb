require "rails_helper"

RSpec.describe GeocodingService do
  describe ".geocode" do
    it "returns lat/lng for a valid address", :vcr do
      stub_nominatim("123 Main St, Springfield, IL",
        [{ "lat" => "39.7817", "lon" => "-89.6501" }])

      result = described_class.geocode("123 Main St, Springfield, IL")

      expect(result[:latitude]).to be_within(0.01).of(39.78)
      expect(result[:longitude]).to be_within(0.01).of(-89.65)
    end

    it "returns nil for an empty address" do
      result = described_class.geocode("")
      expect(result).to be_nil
    end

    it "returns nil for a nil address" do
      result = described_class.geocode(nil)
      expect(result).to be_nil
    end

    it "returns nil when no results are found" do
      stub_nominatim("zzzzzzzzz nowhere", [])

      result = described_class.geocode("zzzzzzzzz nowhere")
      expect(result).to be_nil
    end

    it "returns nil and logs on network error" do
      stub_request(:get, /nominatim\.openstreetmap\.org/)
        .to_raise(Net::ReadTimeout)

      expect(Rails.logger).to receive(:warn).with(/Geocoding failed/)

      result = described_class.geocode("123 Main St")
      expect(result).to be_nil
    end
  end

  def stub_nominatim(query, results)
    stub_request(:get, "https://nominatim.openstreetmap.org/search")
      .with(query: hash_including(q: query, format: "json"))
      .to_return(
        status: 200,
        body: results.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end
