require "rails_helper"

RSpec.describe "Tenant plan enforcement" do
  let(:tenant) { create(:tenant, plan: "free") }
  let(:provider) { create(:provider, tenant: tenant) }

  describe "#plan_allows_appointment?" do
    it "allows appointments under the free plan limit" do
      expect(tenant.plan_allows_appointment?).to be true
    end

    it "blocks appointments when free plan limit is reached" do
      5.times do
        patient = create(:patient, tenant: tenant)
        create(:appointment, tenant: tenant, provider: provider, patient: patient,
          starts_at: Time.current + rand(1..8).hours)
      end

      expect(tenant.plan_allows_appointment?).to be false
    end

    it "always allows appointments on pro plan" do
      tenant.update!(plan: "pro")
      10.times do
        patient = create(:patient, tenant: tenant)
        create(:appointment, tenant: tenant, provider: provider, patient: patient,
          starts_at: Time.current + rand(1..8).hours)
      end

      expect(tenant.plan_allows_appointment?).to be true
    end
  end

  describe "#plan_allows_provider?" do
    it "allows one provider on free plan" do
      expect(tenant.plan_allows_provider?).to be true
    end

    it "blocks additional providers on free plan" do
      create(:provider, tenant: tenant)
      expect(tenant.plan_allows_provider?).to be false
    end

    it "allows unlimited providers on pro plan" do
      tenant.update!(plan: "pro")
      3.times { create(:provider, tenant: tenant) }
      expect(tenant.plan_allows_provider?).to be true
    end
  end

  describe "#trial_active?" do
    it "returns true when trial hasn't expired" do
      tenant.update!(trial_ends_at: 7.days.from_now)
      expect(tenant.trial_active?).to be true
    end

    it "returns false when trial has expired" do
      tenant.update!(trial_ends_at: 1.day.ago)
      expect(tenant.trial_active?).to be false
    end

    it "returns false when no trial date set" do
      tenant.update!(trial_ends_at: nil)
      expect(tenant.trial_active?).to be false
    end
  end
end
