class SmsMessage < ApplicationRecord
  belongs_to :appointment
  belongs_to :patient

  enum :direction, { inbound: 0, outbound: 1 }

  validates :direction, presence: true
  validates :body, presence: true
end
