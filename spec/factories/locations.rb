FactoryBot.define do
  factory :location do
    tenant
    sequence(:name) { |n| "Location #{n}" }
  end
end
