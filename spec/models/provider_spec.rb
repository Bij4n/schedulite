require "rails_helper"

RSpec.describe Provider, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    subject { build(:provider) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe "#display_name" do
    it "returns 'Dr. LastName' by default" do
      provider = build(:provider, first_name: "Sarah", last_name: "Lee")
      expect(provider.display_name).to eq("Dr. Lee")
    end

    it "uses title if set" do
      provider = build(:provider, first_name: "Sarah", last_name: "Lee", title: "NP")
      expect(provider.display_name).to eq("NP Lee")
    end
  end
end
