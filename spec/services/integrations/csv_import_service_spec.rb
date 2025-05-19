require "rails_helper"

RSpec.describe Integrations::CsvImportService do
  let(:tenant) { create(:tenant) }

  let(:csv_content) do
    <<~CSV
      patient_first_name,patient_last_name,patient_phone,provider_name,starts_at
      Alex,Rivera,5551234567,Dr. Sarah Lee,2025-05-20 14:30
      Jordan,Kim,5559876543,Dr. Michael Chen,2025-05-20 15:00
    CSV
  end

  describe ".call" do
    it "returns AppointmentDTOs from CSV data" do
      dtos = described_class.call(csv_content: csv_content, tenant: tenant)
      expect(dtos.length).to eq(2)
    end

    it "maps CSV columns to DTO fields" do
      dtos = described_class.call(csv_content: csv_content, tenant: tenant)
      dto = dtos.first

      expect(dto.patient_first_name).to eq("Alex")
      expect(dto.patient_last_name).to eq("Rivera")
      expect(dto.patient_phone).to eq("5551234567")
      expect(dto.external_source).to eq("csv_import")
      expect(dto.starts_at).to be_present
    end

    it "generates unique external_ids" do
      dtos = described_class.call(csv_content: csv_content, tenant: tenant)
      ids = dtos.map(&:external_id)
      expect(ids.uniq.length).to eq(2)
    end

    it "parses provider name" do
      dtos = described_class.call(csv_content: csv_content, tenant: tenant)
      expect(dtos.first.provider_last_name).to eq("Lee")
    end

    it "handles empty CSV" do
      dtos = described_class.call(csv_content: "patient_first_name,patient_last_name,patient_phone,provider_name,starts_at\n", tenant: tenant)
      expect(dtos).to eq([])
    end
  end
end
