require "rails_helper"

RSpec.describe RoutingService do
  describe ".driving_time" do
    it "returns driving time in minutes" do
      stub_osrm(39.78, -89.65, 41.88, -87.63, duration: 2940.5)

      result = described_class.driving_time(
        from_lat: 39.78, from_lng: -89.65,
        to_lat: 41.88, to_lng: -87.63
      )

      expect(result).to eq(49)
    end

    it "returns nil when coordinates are missing" do
      result = described_class.driving_time(
        from_lat: nil, from_lng: nil,
        to_lat: 41.88, to_lng: -87.63
      )

      expect(result).to be_nil
    end

    it "returns nil on API error" do
      stub_request(:get, /router\.project-osrm\.org/)
        .to_return(status: 200, body: { code: "NoRoute" }.to_json)

      result = described_class.driving_time(
        from_lat: 39.78, from_lng: -89.65,
        to_lat: 41.88, to_lng: -87.63
      )

      expect(result).to be_nil
    end

    it "falls back to haversine estimate on network error" do
      stub_request(:get, /router\.project-osrm\.org/)
        .to_raise(Net::ReadTimeout)

      allow(Rails.logger).to receive(:warn)

      result = described_class.driving_time(
        from_lat: 39.78, from_lng: -89.65,
        to_lat: 41.88, to_lng: -87.63
      )

      expect(result).to be_a(Integer)
      expect(result).to be > 0
    end
  end

  def stub_osrm(from_lat, from_lng, to_lat, to_lng, duration:)
    stub_request(:get, "https://router.project-osrm.org/route/v1/driving/#{from_lng},#{from_lat};#{to_lng},#{to_lat}")
      .with(query: { overview: "false" })
      .to_return(
        status: 200,
        body: {
          code: "Ok",
          routes: [{ duration: duration, distance: 305_000 }]
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end
