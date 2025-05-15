FactoryBot.define do
  factory :gift_card_settings do
    tenant
    delay_threshold_minutes { 20 }
    amount_cents { 1000 }
    merchant_name { "Blue Bottle Coffee" }
  end
end
