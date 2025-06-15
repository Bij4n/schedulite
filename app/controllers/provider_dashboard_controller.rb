class ProviderDashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @provider = find_my_provider
    unless @provider
      redirect_to root_path(force: "admin"), alert: "No provider profile linked to your account"
      return
    end

    @today_appointments = @provider.appointments
                                   .where(starts_at: Date.current.all_day)
                                   .includes(:patient)
                                   .order(:starts_at)

    @upcoming = @provider.appointments
                         .where("starts_at > ?", Time.current)
                         .where.not(status: [:complete, :canceled, :no_show])
                         .includes(:patient)
                         .order(:starts_at)
                         .limit(10)

    @my_patients = @provider.patients.limit(20)
    @clocked_in = current_user.time_entries.where(status: "in_progress").any?
  end

  private

  def find_my_provider
    Provider.find_by(first_name: current_user.first_name, last_name: current_user.last_name, tenant: current_user.tenant)
  end
end
