require "rails_helper"

RSpec.describe LoginEvent, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_inclusion_of(:event_type).in_array(%w[sign_in sign_in_failed sign_out]) }
  end

  describe ".recent" do
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, tenant: tenant) }

    it "returns events in reverse chronological order" do
      old = LoginEvent.create!(user: user, event_type: "sign_in", ip_address: "1.1.1.1", created_at: 2.hours.ago)
      recent = LoginEvent.create!(user: user, event_type: "sign_in", ip_address: "2.2.2.2", created_at: 1.hour.ago)

      expect(LoginEvent.recent.first).to eq(recent)
    end
  end
end
