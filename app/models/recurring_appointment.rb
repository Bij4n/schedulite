class RecurringAppointment < ApplicationRecord
  belongs_to :tenant
  belongs_to :provider
  belongs_to :patient

  acts_as_tenant :tenant

  validates :recurrence_rule, presence: true, inclusion: { in: %w[weekly biweekly monthly] }
  validates :starts_at_time, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def next_occurrence(from: Date.current)
    case recurrence_rule
    when "weekly"
      from + days_until_next(from, 7)
    when "biweekly"
      from + days_until_next(from, 14)
    when "monthly"
      from.next_month.change(day: [from.day, from.next_month.end_of_month.day].min)
    end
  end

  private

  def days_until_next(from, interval)
    # Simple: next occurrence is within the interval
    remaining = interval - ((from - created_at.to_date).to_i % interval)
    remaining == interval ? 0 : remaining
  rescue
    0
  end
end
