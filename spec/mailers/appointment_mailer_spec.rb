require "rails_helper"

RSpec.describe AppointmentMailer, type: :mailer do
  let(:tenant) { create(:tenant, name: "Sunrise Medical") }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera", email: "alex@example.com") }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient, starts_at: Time.current.change(hour: 14, min: 30)) }

  describe "#confirmation" do
    let(:mail) { described_class.confirmation(appointment) }

    it "renders the headers" do
      expect(mail.subject).to include("Appointment Confirmed")
      expect(mail.to).to eq(["alex@example.com"])
      expect(mail.from).to eq(["hello@schedulite.io"])
    end

    it "includes appointment details in the body" do
      expect(mail.body.encoded).to include("Alex")
      expect(mail.body.encoded).to include("2:30 PM")
      expect(mail.body.encoded).to include(provider.display_name)
    end

    it "attaches an .ics calendar file" do
      expect(mail.attachments.count).to eq(1)
      expect(mail.attachments.first.filename).to eq("appointment.ics")
    end
  end

  describe "#delay_notice" do
    let(:mail) { described_class.delay_notice(appointment, delay_minutes: 20) }

    it "notifies patient of the delay" do
      expect(mail.subject).to include("running")
      expect(mail.to).to eq(["alex@example.com"])
      expect(mail.body.encoded).to include("20")
    end
  end

  describe "#daily_digest" do
    let(:owner) { create(:user, tenant: tenant, role: :owner, email: "owner@clinic.com") }
    let(:mail) { described_class.daily_digest(owner) }

    before do
      create(:appointment, tenant: tenant, provider: provider, patient: patient,
        starts_at: Date.current.beginning_of_day + 10.hours)
    end

    it "sends to the owner" do
      expect(mail.to).to eq(["owner@clinic.com"])
    end

    it "includes today's appointment count" do
      expect(mail.body.encoded).to include("1")
    end
  end
end
