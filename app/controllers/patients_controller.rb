class PatientsController < ApplicationController
  before_action :authenticate_user!

  def index
    @patients = Patient.order(:first_name)
    if params[:q].present?
      @patients = Patient.where(phone: params[:q].gsub(/\D/, ""))
    end
  end

  def show
    @patient = Patient.find(params[:id])
    @appointments = @patient.appointments.order(starts_at: :desc).limit(20)
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)

    if @patient.save
      redirect_to patient_path(@patient), notice: "Patient added"
    else
      flash.now[:alert] = @patient.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @patient = Patient.find(params[:id])
  end

  def update
    @patient = Patient.find(params[:id])
    if @patient.update(patient_params)
      redirect_to patient_path(@patient), notice: "Patient updated"
    else
      flash.now[:alert] = @patient.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :phone, :date_of_birth)
  end
end
