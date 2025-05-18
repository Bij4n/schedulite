require "rails_helper"

RSpec.describe ToastComponent, type: :component do
  it "renders success variant" do
    render_inline(described_class.new(message: "Patient checked in", variant: :success))
    expect(page).to have_text("Patient checked in")
    expect(page).to have_css("[data-controller='toast']")
    expect(page).to have_css(".bg-teal-50")
  end

  it "renders error variant" do
    render_inline(described_class.new(message: "Something went wrong", variant: :error))
    expect(page).to have_text("Something went wrong")
    expect(page).to have_css(".bg-red-50")
  end

  it "renders info variant" do
    render_inline(described_class.new(message: "Status updated", variant: :info))
    expect(page).to have_text("Status updated")
    expect(page).to have_css(".bg-blue-50")
  end

  it "includes auto-dismiss data attribute" do
    render_inline(described_class.new(message: "Done", variant: :success))
    expect(page).to have_css("[data-toast-auto-dismiss-value='true']")
  end
end
