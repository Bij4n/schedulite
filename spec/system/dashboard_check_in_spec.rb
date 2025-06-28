require "rails_helper"

RSpec.describe "Dashboard check-in flow", type: :system do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, role: :owner) }
  let(:provider) { create(:provider, tenant: tenant) }
  let!(:patient) { create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera") }
  let!(:appointment) do
    create(:appointment, tenant: tenant, provider: provider, patient: patient,
      starts_at: Time.current.change(hour: 14, min: 30), status: :scheduled)
  end

  before do
    allow(SmsService).to receive(:call)
    sign_in user
  end

  it "signs in and sees today's appointments on the dashboard" do
    visit dashboard_index_path
    expect(page).to have_content("Alex R.")
    expect(page).to have_content("2:30")
  end

  it "shows empty state when no appointments exist" do
    appointment.destroy
    visit dashboard_index_path
    expect(page).to have_content("No appointments for today")
  end

  it "navigates to appointment detail from dashboard" do
    visit dashboard_index_path
    click_link "Alex R."
    expect(page).to have_current_path(appointment_path(appointment))
  end
end
