module Integrations
  class AdapterFactory
    ADAPTERS = {
      "fhir" => "Integrations::FHIRAdapter",
      "calendly" => "Integrations::CalendlyAdapter",
      "google_calendar" => "Integrations::GoogleCalendarAdapter"
    }.freeze

    def self.build(integration)
      adapter_class = ADAPTERS[integration.adapter_type]
      raise ArgumentError, "Unknown adapter type: #{integration.adapter_type}" unless adapter_class

      adapter_class.constantize.new(integration: integration)
    end
  end
end
