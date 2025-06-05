require "rails_helper"

RSpec.describe TimeEntry, type: :model do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  describe "validations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_presence_of(:clock_in_at) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[in_progress completed incomplete]) }
  end

  describe "#duration_hours" do
    it "calculates hours worked minus breaks" do
      entry = TimeEntry.new(clock_in_at: 8.hours.ago, clock_out_at: Time.current, break_minutes_taken: 30)
      expect(entry.duration_hours).to be_within(0.1).of(7.5)
    end

    it "returns 0 when not clocked out" do
      entry = TimeEntry.new(clock_in_at: Time.current, clock_out_at: nil)
      expect(entry.duration_hours).to eq(0)
    end
  end

  describe ".in_progress" do
    it "returns entries where user is currently clocked in" do
      active = TimeEntry.create!(user: user, clock_in_at: 1.hour.ago, status: "in_progress")
      TimeEntry.create!(user: user, clock_in_at: 1.day.ago, clock_out_at: 8.hours.ago, status: "completed")

      expect(TimeEntry.in_progress).to contain_exactly(active)
    end
  end
end
