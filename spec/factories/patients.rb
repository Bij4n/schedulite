FactoryBot.define do
  factory :patient do
    tenant
    first_name { "Alex" }
    last_name { "Rivera" }
    sequence(:phone) { |n| "555#{n.to_s.rjust(7, '0')}" }
    date_of_birth { "1985-06-15" }
    sms_consent { true }
  end
end
