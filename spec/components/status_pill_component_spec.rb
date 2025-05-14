require "rails_helper"

RSpec.describe StatusPillComponent, type: :component do
  it "renders the status text" do
    render_inline(described_class.new(status: "scheduled"))
    expect(page).to have_text("Scheduled")
  end

  it "renders teal classes for checked_in" do
    render_inline(described_class.new(status: "checked_in"))
    expect(page).to have_css(".bg-teal-50")
    expect(page).to have_text("Checked In")
  end

  it "renders blue classes for in_room" do
    render_inline(described_class.new(status: "in_room"))
    expect(page).to have_css(".bg-blue-50")
    expect(page).to have_text("In Room")
  end

  it "renders amber classes for running_late" do
    render_inline(described_class.new(status: "running_late"))
    expect(page).to have_css(".bg-amber-50")
    expect(page).to have_text("Running Late")
  end

  it "renders green classes for complete" do
    render_inline(described_class.new(status: "complete"))
    expect(page).to have_css(".bg-green-50")
    expect(page).to have_text("Complete")
  end

  it "renders gray classes for no_show" do
    render_inline(described_class.new(status: "no_show"))
    expect(page).to have_css(".bg-gray-100")
    expect(page).to have_text("No Show")
  end

  it "renders gray classes for canceled" do
    render_inline(described_class.new(status: "canceled"))
    expect(page).to have_css(".bg-gray-100")
    expect(page).to have_text("Canceled")
  end
end
