require "rails_helper"

RSpec.describe "Patient and Appointment CRUD", type: :system do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, role: :owner) }
  let!(:provider) { create(:provider, tenant: tenant) }

  before do
    allow(SmsService).to receive(:call)
    sign_in user
  end

  describe "patients" do
    it "creates a new patient" do
      visit new_patient_path
      fill_in "First name", with: "Sarah"
      fill_in "Last name", with: "Connor"
      fill_in "Phone", with: "5551234567"
      click_button "Create Patient"

      expect(page).to have_content("Sarah")
    end

    it "lists patients" do
      create(:patient, tenant: tenant, first_name: "Maria", last_name: "Santos")
      visit patients_path
      expect(page).to have_content("Maria")
    end

    it "edits a patient" do
      patient = create(:patient, tenant: tenant, first_name: "Old", last_name: "Name")
      visit edit_patient_path(patient)
      fill_in "First name", with: "New"
      click_button "Update Patient"

      expect(page).to have_content("New")
    end
  end

  describe "appointments" do
    let!(:patient) { create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera") }

    it "creates a new appointment" do
      visit new_appointment_path
      expect(page).to have_content("New Appointment")
    end

    it "shows appointment details" do
      appointment = create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: 1.hour.from_now)
      visit appointment_path(appointment)
      expect(page).to have_content("Alex R.")
    end

    it "cancels an appointment" do
      appointment = create(:appointment, tenant: tenant, provider: provider, patient: patient,
        starts_at: 1.hour.from_now, status: :scheduled)

      page.driver.submit :patch, cancel_appointment_path(appointment), {}
      appointment.reload
      expect(appointment.status).to eq("canceled")
    end
  end
end
