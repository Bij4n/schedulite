FactoryBot.define do
  factory :integration do
    tenant
    adapter_type { "fhir" }
    credentials { { "client_id" => "test", "client_secret" => "test" } }
    status { "active" }
  end
end
