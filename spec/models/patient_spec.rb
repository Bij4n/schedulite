require "rails_helper"

RSpec.describe Patient, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
    it { is_expected.to have_many(:appointments).dependent(:destroy) }
    it { is_expected.to have_many(:sms_messages).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:phone) }
  end

  describe "encryption" do
    let(:tenant) { create(:tenant) }
    let(:patient) { create(:patient, tenant: tenant, first_name: "Jane", last_name: "Doe", phone: "5551234567", date_of_birth: "1990-01-15") }

    it "encrypts first_name" do
      raw = Patient.connection.select_one("SELECT first_name_ciphertext FROM patients WHERE id = #{patient.id}")
      expect(raw["first_name_ciphertext"]).not_to eq("Jane")
      expect(raw["first_name_ciphertext"]).to be_present
    end

    it "encrypts last_name" do
      raw = Patient.connection.select_one("SELECT last_name_ciphertext FROM patients WHERE id = #{patient.id}")
      expect(raw["last_name_ciphertext"]).not_to eq("Doe")
    end

    it "encrypts phone" do
      raw = Patient.connection.select_one("SELECT phone_ciphertext FROM patients WHERE id = #{patient.id}")
      expect(raw["phone_ciphertext"]).not_to eq("5551234567")
    end

    it "encrypts date_of_birth" do
      raw = Patient.connection.select_one("SELECT date_of_birth_ciphertext FROM patients WHERE id = #{patient.id}")
      expect(raw["date_of_birth_ciphertext"]).not_to be_nil
    end

    it "decrypts fields transparently" do
      reloaded = Patient.find(patient.id)
      expect(reloaded.first_name).to eq("Jane")
      expect(reloaded.last_name).to eq("Doe")
      expect(reloaded.phone).to eq("5551234567")
      expect(reloaded.date_of_birth.to_s).to eq("1990-01-15")
    end
  end

  describe "blind index" do
    let(:tenant) { create(:tenant) }

    it "finds patient by phone via blind index" do
      patient = create(:patient, tenant: tenant, phone: "5559876543")
      found = Patient.where(phone: "5559876543").first
      expect(found).to eq(patient)
    end
  end

  describe "auditing" do
    let(:tenant) { create(:tenant) }

    it "creates audit records on create" do
      expect {
        create(:patient, tenant: tenant)
      }.to change(Audited::Audit, :count).by(1)
    end

    it "creates audit records on update" do
      patient = create(:patient, tenant: tenant)
      expect {
        patient.update!(first_name: "Updated")
      }.to change(Audited::Audit, :count).by(1)
    end
  end

  describe "#display_name" do
    it "returns first name and last initial" do
      patient = build(:patient, first_name: "Jane", last_name: "Doe")
      expect(patient.display_name).to eq("Jane D.")
    end
  end
end
