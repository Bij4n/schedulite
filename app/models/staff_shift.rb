class StaffShift < ApplicationRecord
  belongs_to :user

  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, inclusion: { in: %w[proposed approved active inactive] }

  scope :active, -> { where(status: "active") }
  scope :approved, -> { where(status: "approved") }
  scope :proposed, -> { where(status: "proposed") }
  scope :for_day, ->(day) { where(day_of_week: day) }

  def day_name
    DAY_NAMES[day_of_week]
  end

  def hours
    start_minutes = parse_minutes(start_time)
    end_minutes = parse_minutes(end_time)
    ((end_minutes - start_minutes) - break_minutes.to_i) / 60.0
  end

  def active?
    status == "active"
  end

  def proposed?
    status == "proposed"
  end

  private

  def parse_minutes(time_str)
    parts = time_str.to_s.split(":").map(&:to_i)
    parts[0] * 60 + (parts[1] || 0)
  end
end
