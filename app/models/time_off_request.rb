class TimeOffRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: "User", optional: true

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :request_type, presence: true, inclusion: { in: %w[pto sick unpaid personal] }
  validates :status, inclusion: { in: %w[pending approved rejected] }

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :upcoming, -> { where("end_date >= ?", Date.current).order(:start_date) }

  def days
    (end_date - start_date).to_i + 1
  end

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end
end
