require "rails_helper"

RSpec.describe AppointmentPolicy do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient) }

  describe "#check_in?" do
    it "allows owner" do
      user = create(:user, tenant: tenant, role: :owner)
      expect(described_class.new(user, appointment).check_in?).to eq(true)
    end

    it "allows admin" do
      user = create(:user, tenant: tenant, role: :admin)
      expect(described_class.new(user, appointment).check_in?).to eq(true)
    end

    it "allows front_desk" do
      user = create(:user, tenant: tenant, role: :front_desk)
      expect(described_class.new(user, appointment).check_in?).to eq(true)
    end

    it "allows provider" do
      user = create(:user, tenant: tenant, role: :provider)
      expect(described_class.new(user, appointment).check_in?).to eq(true)
    end
  end

  describe "#destroy?" do
    it "allows owner" do
      user = create(:user, tenant: tenant, role: :owner)
      expect(described_class.new(user, appointment).destroy?).to eq(true)
    end

    it "allows admin" do
      user = create(:user, tenant: tenant, role: :admin)
      expect(described_class.new(user, appointment).destroy?).to eq(true)
    end

    it "denies front_desk" do
      user = create(:user, tenant: tenant, role: :front_desk)
      expect(described_class.new(user, appointment).destroy?).to eq(false)
    end

    it "denies provider" do
      user = create(:user, tenant: tenant, role: :provider)
      expect(described_class.new(user, appointment).destroy?).to eq(false)
    end
  end

  describe "#export?" do
    it "allows owner" do
      user = create(:user, tenant: tenant, role: :owner)
      expect(described_class.new(user, appointment).export?).to eq(true)
    end

    it "allows admin" do
      user = create(:user, tenant: tenant, role: :admin)
      expect(described_class.new(user, appointment).export?).to eq(true)
    end

    it "denies front_desk" do
      user = create(:user, tenant: tenant, role: :front_desk)
      expect(described_class.new(user, appointment).export?).to eq(false)
    end

    it "allows provider" do
      user = create(:user, tenant: tenant, role: :provider)
      expect(described_class.new(user, appointment).export?).to eq(true)
    end
  end
end
