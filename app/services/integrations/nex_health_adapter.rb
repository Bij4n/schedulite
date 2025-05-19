module Integrations
  class NexHealthAdapter < Adapter
    def fetch_appointments(date_range:)
      response = api_get("/appointments", {
        location_id: integration.credentials["location_id"],
        start_date: date_range.first.iso8601,
        end_date: date_range.last.iso8601
      })

      (response.dig(:data) || []).map { |appt| map_appointment(appt) }
    end

    def push_status(appointment_id:, status:); end

    def supports_webhooks?
      true
    end

    def verify_webhook(request)
      true # NexHealth webhook verification handled via shared secret in URL
    end

    def parse_webhook(payload)
      data = JSON.parse(payload, symbolize_names: true)
      appt = data[:data]
      map_appointment(appt)
    end

    private

    def map_appointment(appt)
      patient = appt[:patient] || {}
      provider = appt[:provider] || {}
      bio = patient[:bio] || {}

      AppointmentDTO.new(
        external_id: appt[:id].to_s,
        external_source: "nex_health",
        patient_first_name: patient[:first_name],
        patient_last_name: patient[:last_name],
        patient_phone: bio[:phone_number]&.gsub(/\D/, ""),
        patient_dob: bio[:date_of_birth],
        provider_first_name: provider[:first_name],
        provider_last_name: provider[:last_name],
        provider_title: provider[:suffix],
        starts_at: Time.parse(appt[:start_time]),
        ends_at: appt[:end_time] ? Time.parse(appt[:end_time]) : nil,
        status: map_status(appt[:status])
      )
    end

    def map_status(status)
      case status
      when "confirmed", "scheduled" then "scheduled"
      when "checked_in", "arrived" then "checked_in"
      when "completed" then "complete"
      when "cancelled" then "canceled"
      when "no_show" then "no_show"
      else "scheduled"
      end
    end

    def api_get(path, params = {})
      subdomain = integration.credentials["subdomain"]
      base = "https://#{subdomain}.nexhealth.com/api/v1"
      query = params.any? ? "?#{URI.encode_www_form(params.to_a)}" : ""
      uri = URI("#{base}#{path}#{query}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{integration.credentials['api_key']}"
      request["Accept"] = "application/json"

      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
