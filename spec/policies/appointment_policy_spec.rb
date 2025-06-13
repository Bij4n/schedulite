require "rails_helper"

RSpec.describe AppointmentPolicy do
  let(:tenant) { create(:tenant) }
  let(:provider_model) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider_model, patient: patient) }

  describe "#check_in?" do
    it "allows all roles" do
      %i[owner manager staff provider].each do |role|
        user = create(:user, tenant: tenant, role: role)
        expect(described_class.new(user, appointment).check_in?).to eq(true)
      end
    end
  end

  describe "#destroy?" do
    it "allows owner only" do
      user = create(:user, tenant: tenant, role: :owner)
      expect(described_class.new(user, appointment).destroy?).to eq(true)
    end

    it "denies manager" do
      user = create(:user, tenant: tenant, role: :manager)
      expect(described_class.new(user, appointment).destroy?).to eq(false)
    end

    it "denies staff" do
      user = create(:user, tenant: tenant, role: :staff)
      expect(described_class.new(user, appointment).destroy?).to eq(false)
    end

    it "denies provider" do
      user = create(:user, tenant: tenant, role: :provider)
      expect(described_class.new(user, appointment).destroy?).to eq(false)
    end
  end

  describe "#export?" do
    it "allows owner and manager" do
      %i[owner manager].each do |role|
        user = create(:user, tenant: tenant, role: role)
        expect(described_class.new(user, appointment).export?).to eq(true)
      end
    end

    it "denies staff and provider" do
      %i[staff provider].each do |role|
        user = create(:user, tenant: tenant, role: role)
        expect(described_class.new(user, appointment).export?).to eq(false)
      end
    end
  end

  describe "#no_show?" do
    it "allows owner and manager" do
      %i[owner manager].each do |role|
        user = create(:user, tenant: tenant, role: role)
        expect(described_class.new(user, appointment).no_show?).to eq(true)
      end
    end

    it "denies staff and provider" do
      %i[staff provider].each do |role|
        user = create(:user, tenant: tenant, role: role)
        expect(described_class.new(user, appointment).no_show?).to eq(false)
      end
    end
  end
end
