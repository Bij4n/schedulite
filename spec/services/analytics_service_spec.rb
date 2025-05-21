require "rails_helper"

RSpec.describe AnalyticsService do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }

  describe ".daily_summary" do
    it "returns today's appointment counts by status" do
      create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :complete, starts_at: Time.current.change(hour: 9))
      create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :checked_in, starts_at: Time.current.change(hour: 10))
      create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :no_show, starts_at: Time.current.change(hour: 11))

      summary = described_class.daily_summary(tenant: tenant)

      expect(summary[:total]).to eq(3)
      expect(summary[:complete]).to eq(1)
      expect(summary[:checked_in]).to eq(1)
      expect(summary[:no_show]).to eq(1)
    end

    it "returns zero counts when no appointments" do
      summary = described_class.daily_summary(tenant: tenant)
      expect(summary[:total]).to eq(0)
    end
  end

  describe ".no_show_rate" do
    it "calculates percentage of no-shows over a date range" do
      3.times { create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :complete, starts_at: 1.day.ago) }
      create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :no_show, starts_at: 1.day.ago)

      rate = described_class.no_show_rate(tenant: tenant, date_range: 7.days.ago..Date.current)
      expect(rate).to eq(25.0)
    end

    it "returns 0 when no appointments" do
      rate = described_class.no_show_rate(tenant: tenant, date_range: 7.days.ago..Date.current)
      expect(rate).to eq(0)
    end
  end

  describe ".average_wait_minutes" do
    it "calculates average delay across appointments" do
      create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :complete, starts_at: 1.day.ago, delay_minutes: 10)
      create(:appointment, tenant: tenant, provider: provider, patient: patient, status: :complete, starts_at: 1.day.ago, delay_minutes: 20)

      avg = described_class.average_wait_minutes(tenant: tenant, date_range: 7.days.ago..Date.current)
      expect(avg).to eq(15.0)
    end

    it "returns 0 when no delayed appointments" do
      avg = described_class.average_wait_minutes(tenant: tenant, date_range: 7.days.ago..Date.current)
      expect(avg).to eq(0)
    end
  end

  describe ".provider_utilization" do
    it "returns appointment count per provider" do
      provider2 = create(:provider, tenant: tenant, first_name: "Michael", last_name: "Chen")
      3.times { create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: 1.day.ago) }
      2.times { create(:appointment, tenant: tenant, provider: provider2, patient: patient, starts_at: 1.day.ago) }

      util = described_class.provider_utilization(tenant: tenant, date_range: 7.days.ago..Date.current)
      expect(util.find { |u| u[:provider_id] == provider.id }[:count]).to eq(3)
      expect(util.find { |u| u[:provider_id] == provider2.id }[:count]).to eq(2)
    end
  end
end
