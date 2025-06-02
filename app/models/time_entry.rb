class TimeEntry < ApplicationRecord
  belongs_to :user

  validates :clock_in_at, presence: true
  validates :status, inclusion: { in: %w[in_progress completed incomplete] }

  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :for_date_range, ->(range) { where(clock_in_at: range) }

  def duration_minutes
    return 0 unless clock_out_at
    ((clock_out_at - clock_in_at) / 60).round
  end

  def duration_hours
    (duration_minutes - break_minutes_taken.to_i) / 60.0
  end

  def clocked_in?
    status == "in_progress"
  end
end
