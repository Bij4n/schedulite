module Integrations
  class AcuityAdapter < Adapter
    BASE_URL = "https://acuityscheduling.com/api/v1".freeze

    def fetch_appointments(date_range:)
      response = api_get("/appointments", {
        minDate: date_range.first.iso8601,
        maxDate: date_range.last.iso8601
      })

      response.map { |appt| map_appointment(appt) }
    end

    def push_status(appointment_id:, status:); end

    def supports_webhooks?
      true
    end

    def verify_webhook(request)
      true # Acuity uses HTTP Basic auth on webhook URL, verified at controller level
    end

    def parse_webhook(payload)
      data = JSON.parse(payload, symbolize_names: true)
      appt = fetch_appointment(data[:id])
      map_appointment(appt)
    end

    private

    def fetch_appointment(id)
      api_get("/appointments/#{id}")
    end

    def map_appointment(appt)
      provider = parse_provider_name(appt[:calendar])

      AppointmentDTO.new(
        external_id: appt[:id].to_s,
        external_source: "acuity",
        patient_first_name: appt[:firstName],
        patient_last_name: appt[:lastName],
        patient_phone: appt[:phone]&.gsub(/\D/, ""),
        starts_at: Time.parse(appt[:datetime]),
        ends_at: appt[:endTime] ? Time.parse(appt[:endTime]) : nil,
        provider_first_name: provider[:first_name],
        provider_last_name: provider[:last_name],
        provider_title: provider[:title],
        status: appt[:canceled] ? "canceled" : "scheduled"
      )
    end

    def parse_provider_name(calendar_name)
      return { first_name: nil, last_name: nil, title: nil } unless calendar_name
      parts = calendar_name.split(/\s+/)
      title = parts.first if parts.first&.match?(/^(Dr\.|NP|PA|DPT|DC|MD|DO)$/i)
      name_parts = title ? parts[1..] : parts
      { first_name: name_parts[0], last_name: name_parts[1..].join(" "), title: title&.delete(".") }
    end

    def api_get(path, params = {})
      query = params.any? ? "?#{URI.encode_www_form(params.to_a)}" : ""
      uri = URI("#{BASE_URL}#{path}#{query}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(integration.credentials["user_id"], integration.credentials["api_key"])
      request["Accept"] = "application/json"

      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
