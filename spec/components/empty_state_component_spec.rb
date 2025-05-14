require "rails_helper"

RSpec.describe EmptyStateComponent, type: :component do
  it "renders the title" do
    render_inline(described_class.new(title: "No appointments", description: "Nothing today"))
    expect(page).to have_text("No appointments")
  end

  it "renders the description" do
    render_inline(described_class.new(title: "No appointments", description: "Nothing scheduled for today"))
    expect(page).to have_text("Nothing scheduled for today")
  end
end
