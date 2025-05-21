class AnalyticsService
  def self.daily_summary(tenant:, date: Date.current)
    appointments = Appointment.where(tenant: tenant, starts_at: date.all_day)
    counts = appointments.group(:status).count

    {
      total: appointments.count,
      scheduled: counts["scheduled"] || 0,
      checked_in: counts["checked_in"] || 0,
      in_room: counts["in_room"] || 0,
      running_late: counts["running_late"] || 0,
      complete: counts["complete"] || 0,
      no_show: counts["no_show"] || 0,
      canceled: counts["canceled"] || 0
    }
  end

  def self.no_show_rate(tenant:, date_range:)
    appointments = Appointment.where(tenant: tenant, starts_at: date_range)
    total = appointments.count
    return 0 if total.zero?

    no_shows = appointments.where(status: :no_show).count
    (no_shows.to_f / total * 100).round(1)
  end

  def self.average_wait_minutes(tenant:, date_range:)
    appointments = Appointment.where(tenant: tenant, starts_at: date_range)
                              .where.not(delay_minutes: [nil, 0])
    return 0 if appointments.none?

    appointments.average(:delay_minutes).to_f.round(1)
  end

  def self.provider_utilization(tenant:, date_range:)
    Appointment.where(tenant: tenant, starts_at: date_range)
               .group(:provider_id)
               .count
               .map { |provider_id, count| { provider_id: provider_id, count: count } }
  end
end
