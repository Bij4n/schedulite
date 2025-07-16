require "rails_helper"

RSpec.describe "PWA assets", type: :request do
  describe "GET /manifest" do
    it "serves the web app manifest" do
      get "/manifest", headers: { "Accept" => "application/manifest+json" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq("Schedulite")
      expect(json["start_url"]).to eq("/")
      expect(json["display"]).to eq("standalone")
      expect(json["theme_color"]).to be_present
    end
  end

  describe "GET /service-worker" do
    it "serves the service worker" do
      get "/service-worker", headers: { "Accept" => "text/javascript" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("CACHE_NAME")
      expect(response.body).to include("addEventListener")
    end
  end
end
