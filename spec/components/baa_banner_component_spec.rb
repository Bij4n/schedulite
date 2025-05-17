require "rails_helper"

RSpec.describe BaaBannerComponent, type: :component do
  let(:tenant) { create(:tenant) }

  it "renders when tenant has no BAA" do
    render_inline(described_class.new(tenant: tenant))
    expect(page).to have_text("Business Associate Agreement")
  end

  it "does not render when tenant has BAA" do
    tenant.update!(baa_uploaded_at: Time.current)
    render_inline(described_class.new(tenant: tenant))
    expect(page.text).to be_empty
  end
end
