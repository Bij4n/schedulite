require "rails_helper"

RSpec.describe ScheduleConflictService do
  let(:tenant) { create(:tenant, max_hours_per_week: 40) }
  let(:user) { create(:user, tenant: tenant) }

  describe ".detect" do
    it "detects overtime" do
      # 6 days x 8 hours = 48 hrs (over 40 max)
      (1..6).each do |day|
        StaffShift.create!(user: user, day_of_week: day, start_time: "09:00", end_time: "17:00", break_minutes: 0, status: "active")
      end

      conflicts = described_class.detect(tenant: tenant)
      expect(conflicts.any? { |c| c[:type] == "overtime" }).to eq(true)
    end

    it "returns empty when no conflicts" do
      StaffShift.create!(user: user, day_of_week: 1, start_time: "09:00", end_time: "17:00", break_minutes: 30, status: "active")

      conflicts = described_class.detect(tenant: tenant)
      expect(conflicts).to be_empty
    end

    it "detects time-off conflicts with shifts" do
      StaffShift.create!(user: user, day_of_week: Date.current.next_week(:monday).wday, start_time: "09:00", end_time: "17:00", break_minutes: 30, status: "active")
      TimeOffRequest.create!(user: user, start_date: Date.current.next_week(:monday), end_date: Date.current.next_week(:monday), request_type: "pto", status: "approved")

      conflicts = described_class.detect(tenant: tenant)
      expect(conflicts.any? { |c| c[:type] == "time_off" }).to eq(true)
    end
  end
end
