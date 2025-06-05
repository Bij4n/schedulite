require "rails_helper"

RSpec.describe "TimeClock", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  before { sign_in user }

  describe "POST /time_clock/clock_in" do
    it "creates a new time entry" do
      expect {
        post clock_in_time_clock_index_path
      }.to change(TimeEntry, :count).by(1)

      entry = TimeEntry.last
      expect(entry.status).to eq("in_progress")
      expect(entry.user).to eq(user)
    end

    it "does not create duplicate if already clocked in" do
      TimeEntry.create!(user: user, clock_in_at: 1.hour.ago, status: "in_progress")

      expect {
        post clock_in_time_clock_index_path
      }.not_to change(TimeEntry, :count)
    end
  end

  describe "POST /time_clock/clock_out" do
    it "completes the current time entry" do
      entry = TimeEntry.create!(user: user, clock_in_at: 1.hour.ago, status: "in_progress")

      post clock_out_time_clock_index_path
      expect(entry.reload.status).to eq("completed")
      expect(entry.clock_out_at).to be_present
    end
  end

  describe "GET /settings/timesheet" do
    let(:owner) { create(:user, tenant: tenant, role: :owner) }
    before { sign_in owner }

    it "shows timesheet" do
      TimeEntry.create!(user: user, clock_in_at: 8.hours.ago, clock_out_at: Time.current, status: "completed")

      get settings_timesheet_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.full_name)
    end
  end
end
