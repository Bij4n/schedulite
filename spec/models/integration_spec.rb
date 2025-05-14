require "rails_helper"

RSpec.describe Integration, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:adapter_type) }
  end

  describe "encrypted credentials" do
    let(:tenant) { create(:tenant) }

    it "encrypts credentials" do
      integration = create(:integration, tenant: tenant, credentials: { "api_key" => "secret123" })
      raw = Integration.connection.select_one("SELECT credentials_ciphertext FROM integrations WHERE id = #{integration.id}")
      expect(raw["credentials_ciphertext"]).not_to include("secret123")
    end

    it "decrypts credentials transparently" do
      integration = create(:integration, tenant: tenant, credentials: { "api_key" => "secret123" })
      expect(Integration.find(integration.id).credentials).to eq({ "api_key" => "secret123" })
    end
  end
end
