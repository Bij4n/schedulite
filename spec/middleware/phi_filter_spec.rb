require "rails_helper"

RSpec.describe PhiFilter do
  let(:app) { ->(env) { [200, env, ["OK"]] } }
  let(:middleware) { described_class.new(app) }

  it "strips phone numbers from response bodies in logs" do
    expect(described_class.scrub("Patient phone: 555-123-4567 is confirmed"))
      .to eq("Patient phone: [FILTERED] is confirmed")
  end

  it "strips SSN patterns" do
    expect(described_class.scrub("SSN: 123-45-6789"))
      .to eq("SSN: [FILTERED]")
  end

  it "strips date of birth patterns" do
    expect(described_class.scrub("DOB: 1985-06-15"))
      .to eq("DOB: [FILTERED]")
  end

  it "strips email addresses" do
    expect(described_class.scrub("Email: patient@example.com here"))
      .to eq("Email: [FILTERED] here")
  end

  it "does not alter non-PHI text" do
    text = "Appointment at 2:30 PM with Dr. Lee"
    expect(described_class.scrub(text)).to eq(text)
  end

  it "passes requests through unchanged" do
    env = Rack::MockRequest.env_for("/")
    status, _, body = middleware.call(env)
    expect(status).to eq(200)
    expect(body).to eq(["OK"])
  end
end
