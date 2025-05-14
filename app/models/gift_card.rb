class GiftCard < ApplicationRecord
  belongs_to :appointment
  belongs_to :tenant

  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
end
