FactoryBot.define do
  factory :tenant do
    name { "Sunrise Medical" }
    sequence(:subdomain) { |n| "sunrise-#{n}" }
    onboarding_step { 4 }
  end
end
