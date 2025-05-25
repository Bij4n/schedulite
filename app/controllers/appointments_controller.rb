class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointments = Appointment.where(tenant: current_user.tenant)
                               .includes(:patient, :provider)
                               .order(starts_at: :desc)

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
    @providers = Provider.where(tenant: current_user.tenant).order(:last_name)
    @patients = Patient.where(tenant: current_user.tenant).order(:first_name)
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.tenant = current_user.tenant

    if @appointment.save
      redirect_to root_path, notice: "Appointment created"
    else
      @providers = Provider.where(tenant: current_user.tenant).order(:last_name)
      @patients = Patient.where(tenant: current_user.tenant).order(:first_name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def appointment_params
    params.require(:appointment).permit(:patient_id, :provider_id, :starts_at, :notes)
  end
end
