FactoryBot.define do
  factory :tenant do
    name { "Sunrise Medical" }
    sequence(:subdomain) { |n| "sunrise-#{n}" }
  end
end
