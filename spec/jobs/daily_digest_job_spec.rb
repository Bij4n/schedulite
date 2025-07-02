require "rails_helper"

RSpec.describe DailyDigestJob, type: :job do
  let(:tenant) { create(:tenant) }

  it "sends digest to owners" do
    owner = create(:user, tenant: tenant, role: :owner)
    create(:user, tenant: tenant, role: :staff)

    expect {
      described_class.perform_now
    }.to have_enqueued_job(ActionMailer::MailDeliveryJob).once
  end
end
