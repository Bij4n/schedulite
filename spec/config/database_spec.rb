require "rails_helper"

RSpec.describe "Database configuration" do
  describe "production" do
    let(:config) do
      YAML.load(
        ERB.new(File.read(Rails.root.join("config/database.yml"))).result,
        aliases: true
      )
    end

    it "uses postgresql adapter in production" do
      expect(config["production"]["adapter"]).to eq("postgresql")
    end

    it "documents that DATABASE_URL is auto-read by Rails" do
      raw = File.read(Rails.root.join("config/database.yml"))
      expect(raw).to include("DATABASE_URL")
    end

    it "does not pass an empty url to the pg gem" do
      raw = File.read(Rails.root.join("config/database.yml"))
      # Setting `url:` to an empty string makes pg fall back to local
      # Unix sockets when DATABASE_URL is unset, masking the real cause.
      expect(raw).not_to match(/^\s*url:\s*<%=/)
    end

    it "uses sqlite3 for development" do
      expect(config["development"]["adapter"]).to eq("sqlite3")
    end

    it "uses sqlite3 for test" do
      expect(config["test"]["adapter"]).to eq("sqlite3")
    end
  end
end
