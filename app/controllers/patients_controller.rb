class PatientsController < ApplicationController
  before_action :authenticate_user!

  def index
    @patients = Patient.where(tenant: current_user.tenant).order(:first_name)
    @patients = @patients.where("first_name_ciphertext IS NOT NULL") # all patients
    if params[:q].present?
      # Search by phone via blind index
      @patients = Patient.where(tenant: current_user.tenant, phone: params[:q].gsub(/\D/, ""))
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
    @patient.tenant = current_user.tenant

    if @patient.save
      redirect_to patient_path(@patient), notice: "Patient added"
    else
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
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :phone, :date_of_birth)
  end
end
