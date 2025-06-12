class ScheduleConflictService
  def self.detect(tenant:)
    new(tenant: tenant).detect
  end

  def initialize(tenant:)
    @tenant = tenant
  end

  def detect
    conflicts = []
    conflicts += detect_shift_overlaps
    conflicts += detect_time_off_shift_conflicts
    conflicts += detect_overtime
    conflicts
  end

  private

  def detect_shift_overlaps
    conflicts = []
    User.where(tenant: @tenant).find_each do |user|
      shifts = user.staff_shifts.active.order(:day_of_week, :start_time)
      shifts.group_by(&:day_of_week).each do |day, day_shifts|
        next if day_shifts.length < 2
        day_shifts.each_cons(2) do |a, b|
          if a.end_time > b.start_time
            conflicts << { type: "overlap", user: user, message: "#{user.full_name} has overlapping shifts on #{a.day_name}" }
          end
        end
      end
    end
    conflicts
  end

  def detect_time_off_shift_conflicts
    conflicts = []
    TimeOffRequest.approved.upcoming.includes(:user).each do |req|
      (req.start_date..req.end_date).each do |date|
        shifts = req.user.staff_shifts.active.for_day(date.wday)
        if shifts.any?
          conflicts << { type: "time_off", user: req.user, message: "#{req.user.full_name} has approved time off #{req.start_date.strftime('%b %-d')}–#{req.end_date.strftime('%b %-d')} but is scheduled to work #{date.strftime('%A')}" }
          break
        end
      end
    end
    conflicts
  end

  def detect_overtime
    conflicts = []
    max_hours = @tenant.max_hours_per_week || 40

    User.where(tenant: @tenant).find_each do |user|
      weekly_hours = user.staff_shifts.active.sum(&:hours)
      if weekly_hours > max_hours
        conflicts << { type: "overtime", user: user, message: "#{user.full_name} is scheduled for #{weekly_hours.round(1)} hrs/week (max #{max_hours})" }
      end
    end
    conflicts
  end
end
