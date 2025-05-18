module Integrations
  class JaneAppAdapter < Adapter
    def fetch_appointments(date_range:)
      response = api_get("/appointments", {
        clinic_id: integration.credentials["clinic_id"],
        start_at_from: date_range.first.iso8601,
        start_at_to: date_range.last.end_of_day.iso8601
      })

      (response[:appointments] || []).map { |appt| map_appointment(appt) }
    end

    def push_status(appointment_id:, status:)
      # Jane App doesn't support status write-back via API
    end

    def supports_webhooks?
      false
    end

    private

    def map_appointment(appt)
      patient = appt[:patient]
      practitioner = appt[:practitioner]

      AppointmentDTO.new(
        external_id: appt[:id].to_s,
        external_source: "jane_app",
        patient_first_name: patient[:first_name],
        patient_last_name: patient[:last_name],
        patient_phone: patient[:phone]&.gsub(/\D/, ""),
        patient_dob: patient[:date_of_birth],
        provider_first_name: practitioner&.dig(:first_name),
        provider_last_name: practitioner&.dig(:last_name),
        provider_title: practitioner&.dig(:title),
        starts_at: Time.parse(appt[:start_at]),
        ends_at: appt[:end_at] ? Time.parse(appt[:end_at]) : nil,
        status: map_status(appt[:state])
      )
    end

    def map_status(state)
      case state
      when "booked", "confirmed" then "scheduled"
      when "arrived" then "checked_in"
      when "completed" then "complete"
      when "cancelled", "canceled" then "canceled"
      when "no_show" then "no_show"
      else "scheduled"
      end
    end

    def api_get(path, params = {})
      base = integration.credentials["base_url"]
      query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
      uri = URI("#{base}#{path}?#{query}")

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
