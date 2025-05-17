module Integrations
  class CalendlyAdapter < Adapter
    BASE_URL = "https://api.calendly.com".freeze

    def fetch_appointments(date_range:)
      events = fetch_events(date_range)
      events.filter_map do |event|
        invitees = fetch_invitees(event[:uri])
        invitee = invitees.first
        next unless invitee

        build_dto(event, invitee)
      end
    end

    def push_status(appointment_id:, status:)
      # Calendly doesn't support status write-back
    end

    def supports_webhooks?
      true
    end

    def verify_webhook(request)
      signature_header = request.headers["Calendly-Webhook-Signature"]
      return false unless signature_header

      provided_sig = signature_header.sub("v1=", "")
      expected_sig = OpenSSL::HMAC.hexdigest("SHA256", signing_key, request.raw_post)
      ActiveSupport::SecurityUtils.secure_compare(provided_sig, expected_sig)
    end

    def parse_webhook(payload)
      data = JSON.parse(payload, symbolize_names: true)
      invitee = data[:payload]
      event = invitee[:scheduled_event]
      status = data[:event] == "invitee.canceled" ? "canceled" : "scheduled"

      build_dto_from_webhook(event, invitee, status)
    end

    private

    def fetch_events(date_range)
      params = {
        organization: integration.credentials["organization_uri"],
        min_start_time: date_range.first.beginning_of_day.iso8601,
        max_start_time: date_range.last.end_of_day.iso8601,
        status: "active"
      }
      response = api_get("/scheduled_events", params)
      response[:collection] || []
    end

    def fetch_invitees(event_uri)
      event_id = event_uri.split("/").last
      response = api_get("/scheduled_events/#{event_id}/invitees")
      response[:collection] || []
    end

    def build_dto(event, invitee)
      names = parse_name(invitee[:name])
      provider = parse_provider_name(event.dig(:event_memberships, 0, :user_name))
      event_id = event[:uri].split("/").last

      AppointmentDTO.new(
        external_id: event_id,
        external_source: "calendly",
        patient_first_name: names[:first],
        patient_last_name: names[:last],
        patient_phone: normalize_phone(invitee[:text_reminder_number]),
        starts_at: Time.parse(event[:start_time]),
        ends_at: event[:end_time] ? Time.parse(event[:end_time]) : nil,
        provider_first_name: provider[:first_name],
        provider_last_name: provider[:last_name],
        provider_title: provider[:title]
      )
    end

    def build_dto_from_webhook(event, invitee, status)
      names = parse_name(invitee[:name])
      provider = parse_provider_name(event.dig(:event_memberships, 0, :user_name))
      event_id = event[:uri].split("/").last

      AppointmentDTO.new(
        external_id: event_id,
        external_source: "calendly",
        patient_first_name: names[:first],
        patient_last_name: names[:last],
        patient_phone: normalize_phone(invitee[:text_reminder_number]),
        starts_at: Time.parse(event[:start_time]),
        ends_at: event[:end_time] ? Time.parse(event[:end_time]) : nil,
        provider_first_name: provider[:first_name],
        provider_last_name: provider[:last_name],
        provider_title: provider[:title],
        status: status
      )
    end

    def parse_name(full_name)
      parts = (full_name || "").split(/\s+/, 2)
      { first: parts[0] || "Unknown", last: parts[1] || "Unknown" }
    end

    def parse_provider_name(display)
      return { first_name: nil, last_name: nil, title: nil } unless display

      parts = display.split(/\s+/)
      title = parts.first if parts.first.match?(/^(Dr\.|NP|PA|DPT|DC|MD|DO)$/i)
      name_parts = title ? parts[1..] : parts
      { first_name: name_parts[0], last_name: name_parts[1..].join(" "), title: title&.delete(".") }
    end

    def normalize_phone(phone)
      phone&.gsub(/\D/, "")&.last(10)
    end

    def signing_key
      integration.credentials["webhook_signing_key"]
    end

    def api_get(path, params = {})
      query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
      uri = URI("#{BASE_URL}#{path}?#{query}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.request_uri)
      request["Authorization"] = "Bearer #{integration.credentials['api_key']}"
      request["Content-Type"] = "application/json"

      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
