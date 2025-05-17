module Integrations
  class GoogleCalendarAdapter < Adapter
    BASE_URL = "https://www.googleapis.com/calendar/v3".freeze

    def fetch_appointments(date_range:)
      events = fetch_events(date_range)
      events.filter_map { |event| map_event(event) }
    end

    def push_status(appointment_id:, status:)
      # Google Calendar doesn't have appointment status concept
    end

    def supports_webhooks?
      false
    end

    private

    def fetch_events(date_range)
      calendar_id = integration.credentials["calendar_id"] || "primary"
      params = {
        timeMin: date_range.first.beginning_of_day.iso8601,
        timeMax: date_range.last.end_of_day.iso8601,
        singleEvents: true,
        orderBy: "startTime"
      }

      response = api_get("/calendars/#{CGI.escape(calendar_id)}/events", params)
      response[:items] || []
    end

    def map_event(event)
      patient_attendee = find_patient_attendee(event)
      provider_attendee = find_provider_attendee(event)
      patient_name = parse_name(patient_attendee&.dig(:displayName) || extract_name_from_summary(event[:summary]))
      provider_name = parse_provider_name(provider_attendee&.dig(:displayName))
      phone = extract_phone(event[:description])

      AppointmentDTO.new(
        external_id: event[:id],
        external_source: "google_calendar",
        patient_first_name: patient_name[:first],
        patient_last_name: patient_name[:last],
        patient_phone: phone || "",
        starts_at: Time.parse(event.dig(:start, :dateTime)),
        ends_at: event.dig(:end, :dateTime) ? Time.parse(event.dig(:end, :dateTime)) : nil,
        provider_first_name: provider_name[:first_name],
        provider_last_name: provider_name[:last_name],
        provider_title: provider_name[:title],
        status: map_status(event[:status])
      )
    end

    def find_patient_attendee(event)
      attendees = event[:attendees] || []
      attendees.find { |a| !a[:organizer] && !a[:self] }
    end

    def find_provider_attendee(event)
      attendees = event[:attendees] || []
      attendees.find { |a| a[:organizer] }
    end

    def extract_name_from_summary(summary)
      return "Unknown" unless summary
      summary.split(/\s*[-–—]\s*/).first&.strip || summary
    end

    def extract_phone(description)
      return nil unless description
      match = description.match(/(?:phone|tel|mobile|cell)[:\s]*([+\d\s()-]+)/i)
      match ? match[1].gsub(/\D/, "").last(10) : nil
    end

    def parse_name(full_name)
      parts = (full_name || "Unknown").split(/\s+/, 2)
      { first: parts[0], last: parts[1] || "Unknown" }
    end

    def parse_provider_name(display)
      return { first_name: nil, last_name: nil, title: nil } unless display
      parts = display.split(/\s+/)
      title = parts.first if parts.first&.match?(/^(Dr\.|NP|PA|DPT|DC|MD|DO)$/i)
      name_parts = title ? parts[1..] : parts
      { first_name: name_parts[0], last_name: name_parts[1..].join(" "), title: title&.delete(".") }
    end

    def map_status(gcal_status)
      case gcal_status
      when "confirmed" then "scheduled"
      when "cancelled" then "canceled"
      when "tentative" then "scheduled"
      else "scheduled"
      end
    end

    def api_get(path, params = {})
      query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
      uri = URI("#{BASE_URL}#{path}?#{query}")

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
