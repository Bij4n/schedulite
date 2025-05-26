class ProvidersController < ApplicationController
  before_action :authenticate_user!

  def index
    @providers = Provider.order(:last_name)
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

    if @provider.save
      redirect_to provider_path(@provider), notice: "Provider added"
    else
      flash.now[:alert] = @provider.errors.full_messages.join(", ")
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
      flash.now[:alert] = @provider.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def provider_params
    params.require(:provider).permit(:first_name, :last_name, :title)
  end
end
