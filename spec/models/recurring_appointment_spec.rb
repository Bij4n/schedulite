require "rails_helper"

RSpec.describe RecurringAppointment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:patient) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:recurrence_rule) }
    it { is_expected.to validate_inclusion_of(:recurrence_rule).in_array(%w[weekly biweekly monthly]) }
    it { is_expected.to validate_presence_of(:starts_at_time) }
    it { is_expected.to validate_presence_of(:duration_minutes) }
  end

  describe "#next_occurrence" do
    let(:tenant) { create(:tenant) }
    let(:provider) { create(:provider, tenant: tenant) }
    let(:patient) { create(:patient, tenant: tenant) }

    it "returns the next date for a weekly recurrence" do
      recurring = described_class.create!(
        tenant: tenant, provider: provider, patient: patient,
        recurrence_rule: "weekly",
        starts_at_time: "14:30",
        duration_minutes: 30,
        active: true
      )

      next_date = recurring.next_occurrence(from: Date.current)
      expect(next_date).to be >= Date.current
      expect(next_date).to be <= 7.days.from_now.to_date
    end
  end
end
