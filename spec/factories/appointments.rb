FactoryBot.define do
  factory :appointment do
    tenant
    provider
    patient
    starts_at { Time.current.change(hour: 14, min: 30) }
    status { :scheduled }
    notes { nil }
  end
end
