class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(hours_before:)
    window_start = hours_before.hours.from_now - 15.minutes
    window_end = hours_before.hours.from_now + 15.minutes
    template = hours_before >= 24 ? :reminder_24h : :reminder_2h

    Appointment
      .where(status: :scheduled)
      .where(starts_at: window_start..window_end)
      .includes(:patient, :provider)
      .find_each do |appointment|
        next unless appointment.patient.sms_consent?

        SmsService.call(
          patient: appointment.patient,
          appointment: appointment,
          template: template
        )
      end
  end
end
