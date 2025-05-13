FactoryBot.define do
  factory :user do
    tenant
    first_name { "Jane" }
    last_name { "Doe" }
    sequence(:email) { |n| "jane.doe+#{n}@example.com" }
    password { "password123!" }
    role { :front_desk }
  end
end
