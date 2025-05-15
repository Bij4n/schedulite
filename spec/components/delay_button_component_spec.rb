require "rails_helper"

RSpec.describe DelayButtonComponent, type: :component do
  let(:tenant) { create(:tenant) }
  let(:provider) { create(:provider, tenant: tenant) }
  let(:patient) { create(:patient, tenant: tenant) }
  let(:appointment) { create(:appointment, tenant: tenant, provider: provider, patient: patient) }

  it "renders delay buttons" do
    render_inline(described_class.new(appointment: appointment))
    expect(page).to have_button("+5")
    expect(page).to have_button("+10")
    expect(page).to have_button("+15")
    expect(page).to have_button("+30")
  end
end
