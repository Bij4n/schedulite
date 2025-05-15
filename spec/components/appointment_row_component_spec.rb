require "rails_helper"

RSpec.describe AppointmentRowComponent, type: :component do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant, first_name: "Sarah", last_name: "Lee") }
  let(:patient) { create(:patient, tenant: tenant, first_name: "Alex", last_name: "Rivera") }
  let(:appointment) do
    create(:appointment,
      tenant: tenant,
      provider: provider,
      patient: patient,
      starts_at: Time.current.change(hour: 14, min: 30),
      status: :scheduled)
  end

  it "renders the appointment time" do
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_text("2:30 PM")
  end

  it "renders the patient display name" do
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_text("Alex R.")
  end

  it "renders the provider display name" do
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_text("Dr. Lee")
  end

  it "renders the status pill" do
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_text("Scheduled")
  end

  it "wraps in a turbo frame" do
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_css("turbo-frame[id^='appointment_']")
  end

  it "shows check-in button for scheduled appointments" do
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_button("Check In")
  end

  it "shows complete button for checked-in appointments" do
    appointment.update!(status: :checked_in)
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_button("Complete")
  end

  it "shows no action button for completed appointments" do
    appointment.update!(status: :complete)
    render_inline(described_class.new(appointment: appointment))
    expect(page).not_to have_button("Check In")
    expect(page).not_to have_button("Complete")
  end

  it "shows delay info when delay_minutes is set" do
    appointment.update!(status: :running_late, delay_minutes: 15)
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_text("+15min")
  end
end
