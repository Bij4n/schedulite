class ProvidersController < ApplicationController
  before_action :authenticate_user!

  def index
    @providers = Provider.order(:last_name)
  end

  def show
    @provider = Provider.find(params[:id])
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current

    @week_start = @selected_date.beginning_of_week(:monday)
    @week_dates = (0..6).map { |i| @week_start + i.days }

    all_appointments = @provider.appointments
                                .where(starts_at: @week_start.beginning_of_day..(@week_start + 6.days).end_of_day)
                                .includes(:patient)
                                .chronological

    @day_counts = all_appointments.group_by { |a| a.starts_at.to_date }.transform_values(&:count)
    @today_appointments = all_appointments.select { |a| a.starts_at.to_date == @selected_date }
    @week_appointments = all_appointments.group_by { |a| a.starts_at.to_date }

    @upcoming = @provider.appointments
                         .where("starts_at > ?", Time.current)
                         .where.not(status: [:complete, :canceled, :no_show])
                         .includes(:patient)
                         .order(:starts_at)
                         .limit(10)

    @view_mode = params[:view] || "list"
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
