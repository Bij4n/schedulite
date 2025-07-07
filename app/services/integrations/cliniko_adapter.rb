module Integrations
  class ClinikoAdapter < Adapter
    def fetch_appointments(date_range:)
      query = [
        "q[]=starts_at:>=#{CGI.escape(date_range.first.iso8601)}",
        "q[]=starts_at:<=#{CGI.escape(date_range.last.end_of_day.iso8601)}"
      ].join("&")

      response = api_get_raw("/individual_appointments?#{query}")
      (response[:individual_appointments] || []).map { |appt| map_appointment(appt) }
    end

    def push_status(appointment_id:, status:)
      # Cliniko status writes happen via patient_arrived_at field
    end

    def supports_webhooks?
      true
    end

    private

    def map_appointment(appt)
      patient = appt[:patient] || {}
      practitioner = appt[:practitioner] || {}
      phone_number = patient.dig(:patient_phone_numbers, 0, :number)

      AppointmentDTO.new(
        external_id: appt[:id].to_s,
        external_source: "cliniko",
        patient_first_name: patient[:first_name],
        patient_last_name: patient[:last_name],
        patient_phone: phone_number&.gsub(/\D/, ""),
        patient_dob: patient[:date_of_birth],
        provider_first_name: practitioner[:first_name],
        provider_last_name: practitioner[:last_name],
        provider_title: practitioner[:title],
        starts_at: Time.parse(appt[:starts_at]),
        ends_at: appt[:ends_at] ? Time.parse(appt[:ends_at]) : nil,
        status: map_status(appt)
      )
    end

    def map_status(appt)
      return "canceled" if appt[:cancelled_at].present?
      return "checked_in" if appt[:patient_arrived_at].present?
      "scheduled"
    end

    def api_get_raw(path)
      shard = integration.credentials["shard"]
      base = "https://api.#{shard}.cliniko.com/v1"
      uri = URI("#{base}#{path}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(integration.credentials["api_key"], "")
      request["Accept"] = "application/json"
      request["User-Agent"] = "Schedulite (hello@schedulite.io)"

      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
