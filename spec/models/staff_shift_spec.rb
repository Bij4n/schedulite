require "rails_helper"

RSpec.describe StaffShift, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:day_of_week) }
    it { is_expected.to validate_inclusion_of(:day_of_week).in_range(0..6) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[proposed approved active inactive]) }
  end

  describe "scopes" do
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, tenant: tenant) }

    it ".active returns only active shifts" do
      active = StaffShift.create!(user: user, day_of_week: 1, start_time: "09:00", end_time: "17:00", status: "active")
      StaffShift.create!(user: user, day_of_week: 2, start_time: "09:00", end_time: "17:00", status: "proposed")

      expect(StaffShift.active).to contain_exactly(active)
    end

    it ".for_day returns shifts for a specific day" do
      mon = StaffShift.create!(user: user, day_of_week: 1, start_time: "09:00", end_time: "17:00", status: "active")
      StaffShift.create!(user: user, day_of_week: 2, start_time: "09:00", end_time: "17:00", status: "active")

      expect(StaffShift.for_day(1)).to contain_exactly(mon)
    end
  end

  describe "#hours" do
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, tenant: tenant) }

    it "calculates shift duration in hours" do
      shift = StaffShift.new(user: user, day_of_week: 1, start_time: "09:00", end_time: "17:00", break_minutes: 30)
      expect(shift.hours).to eq(7.5)
    end

    it "handles zero break" do
      shift = StaffShift.new(user: user, day_of_week: 1, start_time: "09:00", end_time: "17:00", break_minutes: 0)
      expect(shift.hours).to eq(8.0)
    end
  end

  describe "#day_name" do
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, tenant: tenant) }

    it "returns the weekday name" do
      shift = StaffShift.new(day_of_week: 1)
      expect(shift.day_name).to eq("Monday")
    end
  end
end
