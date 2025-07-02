require "rails_helper"

RSpec.describe TimeOffMailer, type: :mailer do
  let(:tenant) { create(:tenant, name: "Sunrise Medical") }
  let(:requester) { create(:user, tenant: tenant, first_name: "Jane", last_name: "Smith", role: :staff) }
  let(:manager) { create(:user, tenant: tenant, first_name: "Dr.", last_name: "Owner", role: :owner, email: "owner@clinic.com") }

  describe "#request_submitted" do
    let(:mail) { described_class.request_submitted(requester: requester, manager: manager, start_date: Date.new(2025, 7, 4), end_date: Date.new(2025, 7, 6), reason: "Family vacation") }

    it "sends to the manager" do
      expect(mail.to).to eq(["owner@clinic.com"])
      expect(mail.subject).to include("Time Off Request")
    end

    it "includes the request details" do
      expect(mail.body.encoded).to include("Jane Smith")
      expect(mail.body.encoded).to include("July")
    end
  end
end
