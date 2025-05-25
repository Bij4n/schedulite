class ProvidersController < ApplicationController
  before_action :authenticate_user!

  def index
    @providers = Provider.where(tenant: current_user.tenant).order(:last_name)
  end

  def show
    @provider = Provider.find(params[:id])
    @appointments = @provider.appointments.where(starts_at: Date.current.all_day).chronological
    @schedules = ProviderSchedule.where(provider: @provider).order(:day_of_week)
  end

  def new
    @provider = Provider.new
  end

  def create
    @provider = Provider.new(provider_params)
    @provider.tenant = current_user.tenant

    if @provider.save
      redirect_to provider_path(@provider), notice: "Provider added"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @provider = Provider.find(params[:id])
  end

  def update
    @provider = Provider.find(params[:id])
    if @provider.update(provider_params)
      redirect_to provider_path(@provider), notice: "Provider updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def provider_params
    params.require(:provider).permit(:first_name, :last_name, :title)
  end
end
