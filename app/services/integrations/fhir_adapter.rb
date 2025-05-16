module Integrations
  class FHIRAdapter < Adapter
    def fetch_appointments(date_range:)
      bundle = fetch_fhir_appointments(date_range)
      entries = bundle.dig(:entry) || []

      entries.filter_map do |entry|
        resource = entry[:resource]
        next unless resource[:resourceType] == "Appointment"

        map_to_dto(resource)
      end
    end

    def push_status(appointment_id:, status:)
      # FHIR write-back is optional and varies by EHR
    end

    def supports_webhooks?
      false
    end

    private

    def map_to_dto(resource)
      patient_ref = find_participant(resource, "Patient")
      practitioner_ref = find_participant(resource, "Practitioner")

      patient_data = fetch_patient(patient_ref[:reference]) if patient_ref
      practitioner_name = parse_practitioner_name(practitioner_ref[:display]) if practitioner_ref

      AppointmentDTO.new(
        external_id: resource[:id],
        external_source: "fhir",
        patient_first_name: patient_data&.dig(:first_name) || "Unknown",
        patient_last_name: patient_data&.dig(:last_name) || "Unknown",
        patient_phone: patient_data&.dig(:phone) || "",
        patient_dob: patient_data&.dig(:dob),
        provider_first_name: practitioner_name&.dig(:first_name),
        provider_last_name: practitioner_name&.dig(:last_name),
        provider_title: practitioner_name&.dig(:title),
        starts_at: Time.parse(resource[:start]),
        ends_at: resource[:end] ? Time.parse(resource[:end]) : nil,
        status: map_fhir_status(resource[:status])
      )
    end

    def find_participant(resource, type)
      participant = resource[:participant]&.find do |p|
        p.dig(:actor, :reference)&.start_with?("#{type}/")
      end
      participant&.dig(:actor)
    end

    def fetch_patient(reference)
      response = fhir_get("/#{reference}")
      return nil unless response

      phone = response.dig(:telecom)&.find { |t| t[:system] == "phone" }&.dig(:value)
      name = response.dig(:name)&.first

      {
        first_name: name&.dig(:given)&.first,
        last_name: name&.dig(:family),
        phone: phone&.gsub(/\D/, ""),
        dob: response[:birthDate]
      }
    end

    def parse_practitioner_name(display)
      return nil unless display

      parts = display.split(",").map(&:strip)
      last_name = parts[0]
      first_parts = (parts[1] || "").split(/\s+/)
      first_name = first_parts.first
      title = first_parts.last if first_parts.length > 1 && first_parts.last.match?(/^(MD|DO|NP|PA|DPT|DC|PhD)$/i)

      { first_name: first_name, last_name: last_name, title: title }
    end

    def map_fhir_status(fhir_status)
      case fhir_status
      when "booked", "pending", "proposed" then "scheduled"
      when "arrived", "checked-in" then "checked_in"
      when "fulfilled" then "complete"
      when "cancelled" then "canceled"
      when "noshow" then "no_show"
      else "scheduled"
      end
    end

    def fetch_fhir_appointments(date_range)
      params = {
        date: "ge#{date_range.first.iso8601}",
        _count: 100
      }
      query = params.map { |k, v| "#{k}=#{v}" }.join("&")
      fhir_get("/Appointment?#{query}")
    end

    def fhir_get(path)
      uri = URI("#{base_url}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{access_token}"
      request["Accept"] = "application/fhir+json"

      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end

    def base_url
      integration.credentials["base_url"]
    end

    def access_token
      integration.credentials["access_token"]
    end
  end
end
