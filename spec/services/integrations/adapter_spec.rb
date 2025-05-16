require "rails_helper"

RSpec.describe Integrations::Adapter do
  subject(:adapter) { described_class.new(integration: double("Integration")) }

  describe "interface methods" do
    it "defines fetch_appointments" do
      expect { adapter.fetch_appointments(date_range: Date.current..Date.current) }
        .to raise_error(NotImplementedError)
    end

    it "defines push_status" do
      expect { adapter.push_status(appointment_id: "123", status: "checked_in") }
        .to raise_error(NotImplementedError)
    end

    it "defines supports_webhooks?" do
      expect(adapter.supports_webhooks?).to eq(false)
    end

    it "defines verify_webhook" do
      expect { adapter.verify_webhook(double("request")) }
        .to raise_error(NotImplementedError)
    end

    it "defines parse_webhook" do
      expect { adapter.parse_webhook(double("payload")) }
        .to raise_error(NotImplementedError)
    end
  end
end
