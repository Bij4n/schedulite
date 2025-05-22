class ProviderSchedule < ApplicationRecord
  belongs_to :provider

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :slot_duration_minutes, presence: true, numericality: { greater_than: 0 }

  def available_slots
    slots = []
    current = parse_time(start_time)
    end_t = parse_time(end_time)

    while current < end_t
      slots << format_time(current)
      current += slot_duration_minutes.minutes
    end

    slots
  end

  private

  def parse_time(time_value)
    case time_value
    when String
      parts = time_value.split(":").map(&:to_i)
      Time.current.change(hour: parts[0], min: parts[1] || 0)
    when Time, ActiveSupport::TimeWithZone
      time_value
    else
      Time.current.change(hour: 0)
    end
  end

  def format_time(time)
    time.strftime("%H:%M")
  end
end
