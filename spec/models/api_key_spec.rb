require "rails_helper"

RSpec.describe APIKey, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe ".authenticate" do
    let(:tenant) { create(:tenant) }

    it "returns the api key for a valid raw key" do
      api_key = APIKey.create!(tenant: tenant, name: "Test Key")
      raw_key = api_key.raw_key

      found = APIKey.authenticate(raw_key)
      expect(found).to eq(api_key)
    end

    it "returns nil for invalid key" do
      expect(APIKey.authenticate("invalid_key")).to be_nil
    end
  end

  describe "key generation" do
    let(:tenant) { create(:tenant) }

    it "generates a raw key on create" do
      api_key = APIKey.create!(tenant: tenant, name: "Test Key")
      expect(api_key.raw_key).to be_present
      expect(api_key.raw_key.length).to be >= 32
    end

    it "stores a digest, not the raw key" do
      api_key = APIKey.create!(tenant: tenant, name: "Test Key")
      expect(api_key.key_digest).to be_present
      expect(api_key.key_digest).not_to eq(api_key.raw_key)
    end
  end
end
