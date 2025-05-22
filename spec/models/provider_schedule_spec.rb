require "rails_helper"

RSpec.describe ProviderSchedule, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:provider) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:day_of_week) }
    it { is_expected.to validate_inclusion_of(:day_of_week).in_range(0..6) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_presence_of(:slot_duration_minutes) }
    it { is_expected.to validate_numericality_of(:slot_duration_minutes).is_greater_than(0) }
  end

  describe "#available_slots" do
    let(:tenant) { create(:tenant) }
    let(:provider) { create(:provider, tenant: tenant) }

    it "returns time slots within the schedule" do
      schedule = described_class.create!(
        provider: provider,
        day_of_week: 1,
        start_time: "09:00",
        end_time: "12:00",
        slot_duration_minutes: 30
      )

      slots = schedule.available_slots
      expect(slots.length).to eq(6)
      expect(slots.first).to eq("09:00")
      expect(slots.last).to eq("11:30")
    end
  end
end
