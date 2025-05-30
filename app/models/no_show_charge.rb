class NoShowCharge < ApplicationRecord
  belongs_to :appointment
  belongs_to :patient
  belongs_to :tenant

  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending charged failed waived] }

  scope :active, -> { where.not(status: "waived") }

  def amount_dollars
    (amount_cents / 100.0).round(2)
  end

  def charged?
    status == "charged"
  end

  def waived?
    status == "waived"
  end
end
