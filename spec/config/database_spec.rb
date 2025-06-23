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

    it "reads DATABASE_URL from environment" do
      raw = File.read(Rails.root.join("config/database.yml"))
      expect(raw).to include("DATABASE_URL")
    end

    it "uses sqlite3 for development" do
      expect(config["development"]["adapter"]).to eq("sqlite3")
    end

    it "uses sqlite3 for test" do
      expect(config["test"]["adapter"]).to eq("sqlite3")
    end
  end
end
