require "rails_helper"

RSpec.describe Appointment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:patient) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "status enum" do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(scheduled: 0, checked_in: 1, in_room: 2, running_late: 3, complete: 4, no_show: 5, canceled: 6)
    }

    it "defaults to scheduled" do
      appt = Appointment.new
      expect(appt.status).to eq("scheduled")
    end
  end

  describe "encrypted notes" do
    let(:tenant) { create(:tenant) }
    let(:provider) { create(:provider, tenant: tenant) }
    let(:patient) { create(:patient, tenant: tenant) }

    it "encrypts the notes field" do
      appt = create(:appointment, tenant: tenant, provider: provider, patient: patient, notes: "Sensitive info")
      raw = Appointment.connection.select_one("SELECT notes_ciphertext FROM appointments WHERE id = #{appt.id}")
      expect(raw["notes_ciphertext"]).not_to eq("Sensitive info")
      expect(raw["notes_ciphertext"]).to be_present
    end

    it "decrypts notes transparently" do
      appt = create(:appointment, tenant: tenant, provider: provider, patient: patient, notes: "Sensitive info")
      expect(Appointment.find(appt.id).notes).to eq("Sensitive info")
    end
  end

  describe "signed_token" do
    let(:tenant) { create(:tenant) }
    let(:provider) { create(:provider, tenant: tenant) }
    let(:patient) { create(:patient, tenant: tenant) }

    it "generates a signed_token on create" do
      appt = create(:appointment, tenant: tenant, provider: provider, patient: patient)
      expect(appt.signed_token).to be_present
      expect(appt.signed_token.length).to be >= 20
    end

    it "generates unique tokens" do
      appt1 = create(:appointment, tenant: tenant, provider: provider, patient: patient)
      appt2 = create(:appointment, tenant: tenant, provider: provider, patient: patient)
      expect(appt1.signed_token).not_to eq(appt2.signed_token)
    end
  end

  describe ".today scope" do
    let(:tenant) { create(:tenant) }
    let(:provider) { create(:provider, tenant: tenant) }
    let(:patient) { create(:patient, tenant: tenant) }

    it "returns only today's appointments" do
      today_appt = create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: Time.current)
      create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: 1.day.ago)
      create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: 1.day.from_now)

      expect(Appointment.today).to contain_exactly(today_appt)
    end
  end

  describe "auditing" do
    let(:tenant) { create(:tenant) }
    let(:provider) { create(:provider, tenant: tenant) }
    let(:patient) { create(:patient, tenant: tenant) }

    it "creates audit records on status change" do
      appt = create(:appointment, tenant: tenant, provider: provider, patient: patient)
      expect {
        appt.update!(status: :checked_in)
      }.to change(Audited::Audit, :count).by(1)
    end
  end
end
