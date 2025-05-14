FactoryBot.define do
  factory :gift_card do
    appointment
    tenant
    amount_cents { 1000 }
    merchant_name { "Blue Bottle Coffee" }
    square_gan { "GANxxxxxxxxxxxxxxxxxxxxxxx" }
  end
end
