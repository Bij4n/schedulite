require "rails_helper"

RSpec.describe SmsTemplate do
  describe ".render" do
    let(:vars) do
      {
        first_name: "Alex",
        appointment_time: "2:30 PM",
        provider_name: "Dr. Lee",
        delay_minutes: 15,
        status_url: "https://app.schedulite.io/status/abc123"
      }
    end

    it "renders check_in_confirmation" do
      result = described_class.render(:check_in_confirmation, vars)
      expect(result).to include("Alex")
      expect(result).to include("2:30 PM")
      expect(result).not_to be_empty
    end

    it "renders delay_notice with delay minutes" do
      result = described_class.render(:delay_notice, vars)
      expect(result).to include("15")
      expect(result).to include("Alex")
    end

    it "renders youre_next" do
      result = described_class.render(:youre_next, vars)
      expect(result).to include("Alex")
    end

    it "raises for unknown template" do
      expect { described_class.render(:nonexistent, vars) }.to raise_error(KeyError)
    end
  end

  describe ".lint!" do
    it "passes for valid templates" do
      expect { described_class.lint! }.not_to raise_error
    end
  end

  describe "PHI safety" do
    it "no template contains last_name placeholder" do
      described_class::TEMPLATES.each_value do |tmpl|
        expect(tmpl).not_to include("%{last_name}"), "Template contains last_name"
      end
    end

    it "no template contains dob placeholder" do
      described_class::TEMPLATES.each_value do |tmpl|
        expect(tmpl).not_to include("%{dob}"), "Template contains dob"
        expect(tmpl).not_to include("%{date_of_birth}"), "Template contains date_of_birth"
      end
    end

    it "no template contains diagnosis placeholder" do
      described_class::TEMPLATES.each_value do |tmpl|
        expect(tmpl).not_to include("%{diagnosis}"), "Template contains diagnosis"
      end
    end

    it "no template contains reason placeholder" do
      described_class::TEMPLATES.each_value do |tmpl|
        expect(tmpl).not_to include("%{reason}"), "Template contains reason"
      end
    end
  end
end
