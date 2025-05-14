FactoryBot.define do
  factory :sms_message do
    appointment
    patient
    direction { :outbound }
    body { "You're checked in for your 2:30 appointment." }
    twilio_sid { "SM#{SecureRandom.hex(16)}" }
  end
end
