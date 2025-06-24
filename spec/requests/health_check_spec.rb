require "rails_helper"

RSpec.describe "Health check", type: :request do
  describe "GET /health" do
    it "returns 200 when database is healthy" do
      get "/health"

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["checks"]["database"]).to eq("ok")
    end

    it "includes all check categories" do
      get "/health"

      json = response.parsed_body
      expect(json["checks"]).to include("database", "redis", "twilio")
    end

    it "reports overall status" do
      get "/health"

      json = response.parsed_body
      expect(json["status"]).to be_in(%w[ok degraded])
    end

    it "returns 503 when database is down" do
      allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(ActiveRecord::ConnectionNotEstablished)

      get "/health"

      expect(response).to have_http_status(:service_unavailable)
      json = response.parsed_body
      expect(json["status"]).to eq("degraded")
    end
  end
end
