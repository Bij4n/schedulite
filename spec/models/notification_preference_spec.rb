require "rails_helper"

RSpec.describe NotificationPreference, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    subject { build(:notification_preference) }
    it { is_expected.to validate_presence_of(:event_name) }
    it { is_expected.to validate_uniqueness_of(:event_name).scoped_to(:tenant_id) }
  end

  describe ".sms_enabled_for?" do
    let(:tenant) { create(:tenant) }

    it "returns true when preference exists and sms_enabled" do
      create(:notification_preference, tenant: tenant, event_name: "check_in", sms_enabled: true)
      expect(described_class.sms_enabled_for?(tenant: tenant, event: "check_in")).to eq(true)
    end

    it "returns true when no preference exists (default enabled)" do
      expect(described_class.sms_enabled_for?(tenant: tenant, event: "check_in")).to eq(true)
    end

    it "returns false when explicitly disabled" do
      create(:notification_preference, tenant: tenant, event_name: "check_in", sms_enabled: false)
      expect(described_class.sms_enabled_for?(tenant: tenant, event: "check_in")).to eq(false)
    end
  end
end
