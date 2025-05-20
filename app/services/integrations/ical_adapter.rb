module Integrations
  class IcalAdapter < Adapter
    def fetch_appointments(date_range:)
      content = fetch_feed
      events = parse_events(content)

      events.filter_map do |event|
        event_date = event[:dtstart]&.to_date
        next unless event_date && date_range.cover?(event_date)
        map_event(event)
      end
    end

    def push_status(appointment_id:, status:); end

    def supports_webhooks?
      false
    end

    private

    def fetch_feed
      uri = URI(integration.credentials["feed_url"])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
      response.body
    end

    def parse_events(content)
      events = []
      current_event = nil

      content.each_line do |line|
        line = line.strip
        case line
        when "BEGIN:VEVENT"
          current_event = {}
        when "END:VEVENT"
          events << current_event if current_event
          current_event = nil
        when /^(\w+):(.*)$/
          current_event[$1.downcase.to_sym] = $2 if current_event
        end
      end

      events.map do |e|
        e[:dtstart] = parse_ical_datetime(e[:dtstart])
        e[:dtend] = parse_ical_datetime(e[:dtend])
        e
      end
    end

    def parse_ical_datetime(str)
      return nil unless str
      Time.strptime(str, "%Y%m%dT%H%M%S") rescue nil
    end

    def map_event(event)
      name = parse_name_from_summary(event[:summary])
      phone = extract_phone(event[:description])
      provider = parse_provider_name(integration.credentials["provider_name"])

      AppointmentDTO.new(
        external_id: event[:uid] || SecureRandom.uuid,
        external_source: "ical",
        patient_first_name: name[:first],
        patient_last_name: name[:last],
        patient_phone: phone || "",
        starts_at: event[:dtstart],
        ends_at: event[:dtend],
        provider_first_name: provider[:first_name],
        provider_last_name: provider[:last_name],
        provider_title: provider[:title],
        status: map_status(event[:status])
      )
    end

    def parse_name_from_summary(summary)
      return { first: "Unknown", last: "Unknown" } unless summary
      name_part = summary.split(/\s*[-–—]\s*/).first&.strip || summary
      parts = name_part.split(/\s+/, 2)
      { first: parts[0], last: parts[1] || "Unknown" }
    end

    def extract_phone(description)
      return nil unless description
      match = description.match(/(?:phone|tel|mobile|cell)[:\s]*([+\d\s()-]+)/i)
      match ? match[1].gsub(/\D/, "").last(10) : nil
    end

    def parse_provider_name(name)
      return { first_name: nil, last_name: nil, title: nil } unless name
      parts = name.split(/\s+/)
      title = parts.first if parts.first&.match?(/^(Dr\.|NP|PA|DPT|DC|MD|DO|DDS)$/i)
      name_parts = title ? parts[1..] : parts
      { first_name: name_parts[0], last_name: name_parts[1..].join(" "), title: title&.delete(".") }
    end

    def map_status(status)
      case status&.upcase
      when "CONFIRMED", "TENTATIVE" then "scheduled"
      when "CANCELLED" then "canceled"
      else "scheduled"
      end
    end
  end
end
