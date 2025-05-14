FactoryBot.define do
  factory :status_event do
    appointment
    user { nil }
    from_status { "scheduled" }
    to_status { "checked_in" }
    delay_minutes { nil }
    note { nil }
  end
end
