class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointments = Appointment.includes(:patient, :provider).order(starts_at: :desc)

    if params[:date].present?
      date = Date.parse(params[:date])
      @appointments = @appointments.where(starts_at: date.all_day)
    end

    if params[:provider_id].present?
      @appointments = @appointments.where(provider_id: params[:provider_id])
    end

    @appointments = @appointments.limit(50)
  end

  def show
    @appointment = Appointment.includes(:patient, :provider, :status_events).find(params[:id])
  end

  def new
    @appointment = Appointment.new(starts_at: Time.current.change(min: 0) + 1.hour)
    @providers = Provider.order(:created_at)
    @patients = Patient.order(:created_at)
  end

  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
      redirect_to root_path, notice: "Appointment created"
    else
      @providers = Provider.order(:created_at)
      @patients = Patient.order(:created_at)
      flash.now[:alert] = @appointment.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def calendar
    @appointment = Appointment.includes(:patient, :provider).find(params[:id])
    ics = generate_ics(@appointment)
    send_data ics, filename: "appointment-#{@appointment.id}.ics", type: "text/calendar", disposition: "attachment"
  end

  private

  def appointment_params
    params.require(:appointment).permit(:patient_id, :provider_id, :starts_at, :notes)
  end

  def generate_ics(appointment)
    ends_at = appointment.ends_at || (appointment.starts_at + 30.minutes)
    tenant = appointment.tenant

    <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Schedulite//EN
      CALSCALE:GREGORIAN
      METHOD:REQUEST
      BEGIN:VEVENT
      UID:appointment-#{appointment.id}@#{tenant.subdomain}.schedulite.com
      DTSTART:#{appointment.starts_at.utc.strftime('%Y%m%dT%H%M%SZ')}
      DTEND:#{ends_at.utc.strftime('%Y%m%dT%H%M%SZ')}
      SUMMARY:Appointment with #{appointment.provider.display_name}
      DESCRIPTION:Your appointment at #{tenant.name}
      LOCATION:#{tenant.name}
      STATUS:CONFIRMED
      END:VEVENT
      END:VCALENDAR
    ICS
  end
end
