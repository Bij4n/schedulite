module Integrations
  class ChiroTouchAdapter < Adapter
    def fetch_appointments(date_range:)
      response = api_get("/appointments", {
        clinic_id: integration.credentials["clinic_id"],
        from: date_range.first.iso8601,
        to: date_range.last.end_of_day.iso8601
      })

      (response[:data] || []).map { |appt| map_appointment(appt) }
    end

    def push_status(appointment_id:, status:)
      # ChiroTouch supports status writes via PATCH
    end

    def supports_webhooks?
      false
    end

    private

    def map_appointment(appt)
      patient = appt[:patient] || {}
      provider = appt[:provider] || {}

      AppointmentDTO.new(
        external_id: appt[:appointment_id].to_s,
        external_source: "chiro_touch",
        patient_first_name: patient[:first_name],
        patient_last_name: patient[:last_name],
        patient_phone: patient[:primary_phone]&.gsub(/\D/, ""),
        patient_dob: patient[:dob],
        provider_first_name: provider[:first_name],
        provider_last_name: provider[:last_name],
        provider_title: provider[:credentials],
        starts_at: Time.parse(appt[:start_time]),
        ends_at: appt[:end_time] ? Time.parse(appt[:end_time]) : nil,
        status: map_status(appt[:status])
      )
    end

    def map_status(status)
      case status
      when "scheduled" then "scheduled"
      when "checked_in", "arrived" then "checked_in"
      when "complete", "completed" then "complete"
      when "canceled", "cancelled" then "canceled"
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
