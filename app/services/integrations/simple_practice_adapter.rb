module Integrations
  class SimplePracticeAdapter < Adapter
    def fetch_appointments(date_range:)
      response = api_get("/appointments", {
        filter: { start_date: date_range.first.iso8601, end_date: date_range.last.iso8601 }
      })

      (response.dig(:data) || []).map { |appt| map_appointment(appt) }
    end

    def push_status(appointment_id:, status:); end

    def supports_webhooks?
      false
    end

    private

    def map_appointment(appt)
      attrs = appt[:attributes]
      client = fetch_resource("/clients/#{appt.dig(:relationships, :client, :data, :id)}")
      practitioner = fetch_resource("/practitioners/#{appt.dig(:relationships, :practitioner, :data, :id)}")

      client_attrs = client.dig(:data, :attributes) || {}
      prac_attrs = practitioner.dig(:data, :attributes) || {}

      AppointmentDTO.new(
        external_id: appt[:id].to_s,
        external_source: "simple_practice",
        patient_first_name: client_attrs[:first_name],
        patient_last_name: client_attrs[:last_name],
        patient_phone: client_attrs[:phone_number]&.gsub(/\D/, ""),
        patient_dob: client_attrs[:date_of_birth],
        provider_first_name: prac_attrs[:first_name],
        provider_last_name: prac_attrs[:last_name],
        provider_title: prac_attrs[:credential],
        starts_at: Time.parse(attrs[:start_time]),
        ends_at: attrs[:end_time] ? Time.parse(attrs[:end_time]) : nil,
        status: map_status(attrs[:status])
      )
    end

    def fetch_resource(path)
      api_get(path)
    end

    def map_status(status)
      case status
      when "confirmed", "scheduled" then "scheduled"
      when "checked_in" then "checked_in"
      when "completed" then "complete"
      when "cancelled" then "canceled"
      when "no_show" then "no_show"
      else "scheduled"
      end
    end

    def api_get(path, params = {})
      base = integration.credentials["base_url"]
      query = params.any? ? "?#{URI.encode_www_form(params.to_a)}" : ""
      uri = URI("#{base}#{path}#{query}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{integration.credentials['access_token']}"
      request["Accept"] = "application/json"

      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
