class GiftCardSettings < ApplicationRecord
  belongs_to :tenant

  validates :delay_threshold_minutes, presence: true, numericality: { greater_than: 0 }
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
end
