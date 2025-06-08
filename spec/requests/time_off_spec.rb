require "rails_helper"

RSpec.describe "TimeOff", type: :request do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:owner) { create(:user, tenant: tenant, role: :owner) }

  describe "POST /time_off" do
    before { sign_in user }

    it "creates a time-off request" do
      expect {
        post time_off_requests_path, params: {
          time_off_request: { start_date: 1.week.from_now, end_date: 1.week.from_now + 2.days, request_type: "pto", reason: "Vacation" }
        }
      }.to change(TimeOffRequest, :count).by(1)

      expect(TimeOffRequest.last.status).to eq("pending")
    end
  end

  describe "PATCH /time_off/:id/approve" do
    before { sign_in owner }

    it "approves a request" do
      request = TimeOffRequest.create!(user: user, start_date: 1.week.from_now, end_date: 1.week.from_now + 2.days, request_type: "pto", status: "pending")

      patch approve_time_off_request_path(request)
      expect(request.reload.status).to eq("approved")
      expect(request.approved_by).to eq(owner)
    end
  end

  describe "PATCH /time_off/:id/reject" do
    before { sign_in owner }

    it "rejects a request" do
      request = TimeOffRequest.create!(user: user, start_date: 1.week.from_now, end_date: 1.week.from_now + 2.days, request_type: "pto", status: "pending")

      patch reject_time_off_request_path(request)
      expect(request.reload.status).to eq("rejected")
    end
  end

  describe "GET /settings/time_off" do
    before { sign_in owner }

    it "shows pending requests" do
      TimeOffRequest.create!(user: user, start_date: 1.week.from_now, end_date: 1.week.from_now + 2.days, request_type: "pto", status: "pending")

      get settings_time_off_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.full_name)
    end
  end
end
