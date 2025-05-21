require "rails_helper"

RSpec.describe PatientFeedback, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:appointment) }
    it { is_expected.to belong_to(:patient) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:rating) }
    it { is_expected.to validate_inclusion_of(:rating).in_range(1..5) }
  end

  describe ".average_rating" do
    let(:tenant) { create(:tenant) }
    let(:provider) { create(:provider, tenant: tenant) }
    let(:patient) { create(:patient, tenant: tenant) }

    it "calculates average across feedbacks" do
      appt1 = create(:appointment, tenant: tenant, provider: provider, patient: patient)
      appt2 = create(:appointment, tenant: tenant, provider: provider, patient: patient)
      PatientFeedback.create!(appointment: appt1, patient: patient, rating: 5)
      PatientFeedback.create!(appointment: appt2, patient: patient, rating: 3)

      expect(PatientFeedback.average_rating).to eq(4.0)
    end
  end
end
