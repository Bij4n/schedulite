class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_owner_or_manager
  before_action :set_location, only: [:edit, :update, :destroy]

  def index
    @locations = Location.order(:name)
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    @location.tenant = current_user.tenant

    if @location.save
      redirect_to locations_path, notice: "Location added"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to locations_path, notice: "Location updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to locations_path, notice: "Location removed"
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :address, :city, :state, :zip, :lunch_start, :lunch_end, :no_show_fee_cents)
  end

  def require_owner_or_manager
    unless current_user.role.in?(%w[owner manager])
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
