require "rails_helper"

RSpec.describe "Sidekiq cron schedule" do
  let(:schedule) do
    YAML.load_file(Rails.root.join("config/sidekiq_cron.yml"))
  end

  it "schedules 24-hour appointment reminders" do
    job = schedule["reminder_24h"]
    expect(job).to be_present
    expect(job["class"]).to eq("AppointmentReminderJob")
    expect(job["cron"]).to be_present
    expect(job["args"]).to include("hours_before" => 24)
  end

  it "schedules 2-hour appointment reminders" do
    job = schedule["reminder_2h"]
    expect(job).to be_present
    expect(job["class"]).to eq("AppointmentReminderJob")
    expect(job["args"]).to include("hours_before" => 2)
  end

  it "schedules daily data retention cleanup" do
    job = schedule["data_retention"]
    expect(job).to be_present
    expect(job["class"]).to eq("DataRetentionJob")
  end

  it "schedules integration sync every 15 minutes" do
    job = schedule["integration_sync"]
    expect(job).to be_present
    expect(job["class"]).to eq("IntegrationSyncAllJob")
  end
end
