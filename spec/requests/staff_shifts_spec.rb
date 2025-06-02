require "rails_helper"

RSpec.describe "StaffShifts", type: :request do
  let(:tenant) { create(:tenant) }
  let(:owner) { create(:user, tenant: tenant, role: :owner) }
  let(:staff) { create(:user, tenant: tenant, role: :front_desk) }

  before { sign_in owner }

  describe "GET /settings/staff/:user_id/shifts" do
    it "shows the staff member's schedule" do
      StaffShift.create!(user: staff, day_of_week: 1, start_time: "09:00", end_time: "17:00", status: "active")

      get settings_staff_shifts_path(staff)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Monday")
    end
  end

  describe "POST /settings/staff/:user_id/shifts" do
    it "creates a shift" do
      expect {
        post settings_staff_shifts_path(staff), params: {
          staff_shift: { day_of_week: 1, start_time: "09:00", end_time: "17:00", break_minutes: 30 }
        }
      }.to change(StaffShift, :count).by(1)

      expect(StaffShift.last.status).to eq("proposed")
    end
  end

  describe "PATCH /settings/staff/:user_id/shifts/:id/approve" do
    it "approves a proposed shift" do
      shift = StaffShift.create!(user: staff, day_of_week: 1, start_time: "09:00", end_time: "17:00", status: "proposed")

      patch approve_settings_staff_shift_path(staff, shift)
      expect(shift.reload.status).to eq("active")
    end
  end

  describe "DELETE /settings/staff/:user_id/shifts/:id" do
    it "removes a shift" do
      shift = StaffShift.create!(user: staff, day_of_week: 1, start_time: "09:00", end_time: "17:00", status: "active")

      expect {
        delete settings_staff_shift_path(staff, shift)
      }.to change(StaffShift, :count).by(-1)
    end
  end
end
