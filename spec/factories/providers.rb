FactoryBot.define do
  factory :provider do
    tenant
    first_name { "Sarah" }
    last_name { "Lee" }
    title { nil }
  end
end
