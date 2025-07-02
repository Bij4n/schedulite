class AppointmentMailer < ApplicationMailer
  def confirmation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @tenant = appointment.tenant

    attachments["appointment.ics"] = generate_ics

    mail(
      to: @patient.email,
      subject: "Appointment Confirmed — #{@appointment.starts_at.strftime('%B %-d at %-l:%M %p')}"
    )
  end

  def delay_notice(appointment, delay_minutes:)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider
    @tenant = appointment.tenant
    @delay_minutes = delay_minutes
    @new_time = (appointment.starts_at + delay_minutes.minutes).strftime("%-l:%M %p")

    mail(
      to: @patient.email,
      subject: "Your provider is running #{delay_minutes} minutes behind"
    )
  end

  def daily_digest(user)
    @user = user
    @tenant = user.tenant

    ActsAsTenant.with_tenant(@tenant) do
      @appointments = Appointment
        .where(starts_at: Date.current.beginning_of_day..Date.current.end_of_day)
        .includes(:patient, :provider)
        .order(:starts_at)
      @count = @appointments.count
    end

    mail(
      to: user.email,
      subject: "Daily Schedule — #{Date.current.strftime('%B %-d, %Y')} (#{@count} appointments)"
    )
  end

  private

  def generate_ics
    start_time = @appointment.starts_at.utc.strftime("%Y%m%dT%H%M%SZ")
    end_time = (@appointment.starts_at + (@appointment.duration_minutes || 30).minutes).utc.strftime("%Y%m%dT%H%M%SZ")

    <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Schedulite//EN
      BEGIN:VEVENT
      DTSTART:#{start_time}
      DTEND:#{end_time}
      SUMMARY:Appointment with #{@provider.display_name}
      DESCRIPTION:Your appointment at #{@tenant.name}
      END:VEVENT
      END:VCALENDAR
    ICS
  end
end
