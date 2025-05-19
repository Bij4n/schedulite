require "csv"

module Integrations
  class CsvImportService
    def self.call(csv_content:, tenant:)
      new(csv_content: csv_content, tenant: tenant).call
    end

    def initialize(csv_content:, tenant:)
      @csv_content = csv_content
      @tenant = tenant
    end

    def call
      rows = CSV.parse(@csv_content, headers: true, header_converters: :symbol)
      rows.filter_map { |row| map_row(row) }
    end

    private

    def map_row(row)
      return nil if row[:patient_first_name].blank?

      provider = parse_provider_name(row[:provider_name])

      AppointmentDTO.new(
        external_id: generate_external_id(row),
        external_source: "csv_import",
        patient_first_name: row[:patient_first_name]&.strip,
        patient_last_name: row[:patient_last_name]&.strip,
        patient_phone: row[:patient_phone]&.gsub(/\D/, ""),
        patient_dob: row[:patient_dob],
        provider_first_name: provider[:first_name],
        provider_last_name: provider[:last_name],
        provider_title: provider[:title],
        starts_at: Time.parse(row[:starts_at]),
        ends_at: row[:ends_at].present? ? Time.parse(row[:ends_at]) : nil
      )
    end

    def parse_provider_name(name)
      return { first_name: nil, last_name: nil, title: nil } unless name
      parts = name.strip.split(/\s+/)
      title = parts.first if parts.first&.match?(/^(Dr\.|NP|PA|DPT|DC|MD|DO|DDS)$/i)
      name_parts = title ? parts[1..] : parts
      { first_name: name_parts[0], last_name: name_parts[1..].join(" "), title: title&.delete(".") }
    end

    def generate_external_id(row)
      content = "#{row[:patient_phone]}_#{row[:starts_at]}_#{@tenant.id}"
      Digest::SHA256.hexdigest(content)[0..15]
    end
  end
end
