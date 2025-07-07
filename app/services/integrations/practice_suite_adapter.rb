module Integrations
  class PracticeSuiteAdapter < Adapter
    def fetch_appointments(date_range:)
      response = api_get("/appointments", {
        practiceId: integration.credentials["practice_id"],
        startDate: date_range.first.iso8601,
        endDate: date_range.last.end_of_day.iso8601
      })

      (response[:appointments] || []).map { |appt| map_appointment(appt) }
    end

    def push_status(appointment_id:, status:)
      # PracticeSuite supports status writes
    end

    def supports_webhooks?
      false
    end

    private

    def map_appointment(appt)
      patient = appt[:patientInfo] || {}
      provider = appt[:providerInfo] || {}
      starts_at = Time.parse(appt[:appointmentTime])
      duration = appt[:duration].to_i

      AppointmentDTO.new(
        external_id: appt[:id].to_s,
        external_source: "practice_suite",
        patient_first_name: patient[:firstName],
        patient_last_name: patient[:lastName],
        patient_phone: patient[:phone]&.gsub(/\D/, ""),
        patient_dob: patient[:birthDate],
        provider_first_name: provider[:firstName],
        provider_last_name: provider[:lastName],
        provider_title: provider[:specialty],
        starts_at: starts_at,
        ends_at: duration > 0 ? starts_at + duration.minutes : nil,
        status: map_status(appt[:state])
      )
    end

    def map_status(state)
      case state.to_s.downcase
      when "scheduled" then "scheduled"
      when "checkedin", "checked_in" then "checked_in"
      when "completed" then "complete"
      when "canceled", "cancelled" then "canceled"
      when "noshow", "no_show" then "no_show"
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
