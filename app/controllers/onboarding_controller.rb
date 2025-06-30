class OnboardingController < ApplicationController
  before_action :authenticate_user!

  STEPS = [
    { title: "Practice Info", description: "Confirm your practice details" },
    { title: "Add a Provider", description: "Set up your first provider" },
    { title: "Add a Patient", description: "Add your first patient" },
    { title: "Create an Appointment", description: "Schedule your first appointment" }
  ].freeze

  TOTAL_STEPS = STEPS.length

  def index
    if current_tenant.onboarding_step >= TOTAL_STEPS
      redirect_to dashboard_index_path
      return
    end

    @step = current_tenant.onboarding_step
    @step_info = STEPS[@step]
    @total_steps = TOTAL_STEPS
  end

  def update
    advance_step
    redirect_to next_destination
  end

  def skip
    advance_step
    redirect_to next_destination
  end

  private

  def current_tenant
    current_user.tenant
  end

  def advance_step
    new_step = [current_tenant.onboarding_step + 1, TOTAL_STEPS].min
    current_tenant.update!(onboarding_step: new_step)
  end

  def next_destination
    current_tenant.onboarding_step >= TOTAL_STEPS ? dashboard_index_path : onboarding_index_path
  end
end
