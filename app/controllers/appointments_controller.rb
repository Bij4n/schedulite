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
    @providers = Provider.order(:last_name)
    @patients = Patient.order(:first_name)
  end

  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
      redirect_to root_path, notice: "Appointment created"
    else
      @providers = Provider.order(:last_name)
      @patients = Patient.order(:first_name)
      flash.now[:alert] = @appointment.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:patient_id, :provider_id, :starts_at, :notes)
  end
end
