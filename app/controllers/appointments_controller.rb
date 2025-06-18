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
    @appointment = Appointment.new(starts_at: Time.current.change(min: 0) + 1.hour, duration_minutes: 30)
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

  def edit
    @appointment = Appointment.find(params[:id])
    @providers = Provider.order(:created_at)
  end

  def update
    @appointment = Appointment.find(params[:id])

    if @appointment.update(reschedule_params)
      redirect_to appointment_path(@appointment), notice: "Appointment rescheduled"
    else
      @providers = Provider.order(:created_at)
      flash.now[:alert] = @appointment.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    @appointment = Appointment.find(params[:id])
    result = StatusChangeService.call(
      appointment: @appointment,
      user: current_user,
      new_status: "canceled",
      note: "Canceled by #{current_user.full_name}"
    )

    if result.success?
      redirect_to root_path, notice: "Appointment canceled"
    else
      redirect_to appointment_path(@appointment), alert: result.error
    end
  end

  def no_show
    @appointment = Appointment.find(params[:id])
    result = StatusChangeService.call(
      appointment: @appointment,
      user: current_user,
      new_status: "no_show",
      note: "No-show marked by #{current_user.full_name}"
    )

    if result.success?
      charge = NoShowBillingService.call(appointment: @appointment)
      if charge&.charged?
        redirect_to appointment_path(@appointment), notice: "Marked as no-show. Fee of $#{'%.2f' % charge.amount_dollars} charged."
      elsif charge&.status == "failed"
        redirect_to appointment_path(@appointment), alert: "Marked as no-show. Fee charge failed."
      else
        redirect_to appointment_path(@appointment), notice: "Marked as no-show."
      end
    else
      redirect_to appointment_path(@appointment), alert: result.error
    end
  end

  def waive_charge
    @appointment = Appointment.find(params[:id])
    charge = @appointment.no_show_charges.find_by(status: %w[charged pending])
    if charge
      charge.update!(status: "waived")
      redirect_to appointment_path(@appointment), notice: "Charge waived"
    else
      redirect_to appointment_path(@appointment), alert: "No charge to waive"
    end
  end

  def calendar
    @appointment = Appointment.includes(:patient, :provider).find(params[:id])
    ics = generate_ics(@appointment)
    send_data ics, filename: "appointment-#{@appointment.id}.ics", type: "text/calendar", disposition: "attachment"
  end

  private

  def appointment_params
    params.require(:appointment).permit(:patient_id, :provider_id, :starts_at, :duration_minutes, :notes)
  end

  def reschedule_params
    params.require(:appointment).permit(:provider_id, :starts_at, :duration_minutes, :notes)
  end

  def generate_ics(appointment)
    duration = appointment.duration_minutes || 30
    ends_at = appointment.ends_at || (appointment.starts_at + duration.minutes)
    tenant = appointment.tenant

    <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Schedulite//EN
      CALSCALE:GREGORIAN
      METHOD:REQUEST
      BEGIN:VEVENT
      UID:appointment-#{appointment.id}@#{tenant.subdomain}.schedulite.io
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
