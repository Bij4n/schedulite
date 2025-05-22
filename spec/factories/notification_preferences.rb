FactoryBot.define do
  factory :notification_preference do
    tenant
    event_name { "check_in" }
    sms_enabled { true }
    email_enabled { false }
  end
end
