require "rails_helper"

RSpec.describe Tenant, type: :model do
  describe "validations" do
    subject { build(:tenant) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:subdomain) }
    it { is_expected.to validate_uniqueness_of(:subdomain).case_insensitive }
    it { is_expected.to validate_length_of(:subdomain).is_at_least(3).is_at_most(63) }
  end

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:destroy) }
  end

  describe "subdomain format" do
    it "rejects subdomains with spaces" do
      tenant = build(:tenant, subdomain: "my practice")
      expect(tenant).not_to be_valid
    end

    it "rejects subdomains with special characters" do
      tenant = build(:tenant, subdomain: "my_practice!")
      expect(tenant).not_to be_valid
    end

    it "allows lowercase alphanumeric with hyphens" do
      tenant = build(:tenant, subdomain: "my-practice-123")
      expect(tenant).to be_valid
    end

    it "normalizes subdomain to lowercase" do
      tenant = create(:tenant, subdomain: "MyPractice")
      expect(tenant.subdomain).to eq("mypractice")
    end
  end
end
