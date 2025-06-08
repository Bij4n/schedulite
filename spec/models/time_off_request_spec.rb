require "rails_helper"

RSpec.describe TimeOffRequest, type: :model do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  describe "validations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:approved_by).optional }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_presence_of(:request_type) }
    it { is_expected.to validate_inclusion_of(:request_type).in_array(%w[pto sick unpaid personal]) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending approved rejected]) }
  end

  describe "#days" do
    it "calculates number of days" do
      req = TimeOffRequest.new(start_date: Date.current, end_date: Date.current + 4.days)
      expect(req.days).to eq(5)
    end
  end

  describe "scopes" do
    it ".pending returns only pending requests" do
      pending_req = TimeOffRequest.create!(user: user, start_date: 1.week.from_now, end_date: 1.week.from_now + 2.days, request_type: "pto", status: "pending")
      TimeOffRequest.create!(user: user, start_date: 2.weeks.from_now, end_date: 2.weeks.from_now + 1.day, request_type: "sick", status: "approved")

      expect(TimeOffRequest.pending).to contain_exactly(pending_req)
    end
  end
end
