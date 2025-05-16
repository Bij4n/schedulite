module Integrations
  class Adapter
    attr_reader :integration

    def initialize(integration:)
      @integration = integration
    end

    def fetch_appointments(date_range:)
      raise NotImplementedError, "#{self.class}#fetch_appointments must be implemented"
    end

    def push_status(appointment_id:, status:)
      raise NotImplementedError, "#{self.class}#push_status must be implemented"
    end

    def supports_webhooks?
      false
    end

    def verify_webhook(request)
      raise NotImplementedError, "#{self.class}#verify_webhook must be implemented"
    end

    def parse_webhook(payload)
      raise NotImplementedError, "#{self.class}#parse_webhook must be implemented"
    end
  end
end
