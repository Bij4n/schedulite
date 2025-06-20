class DelayWorkflowsController < ApplicationController
  before_action :authenticate_user!

  def new
    @provider = Provider.find(params[:provider_id])
    @templates = DelayWorkflowTemplate.all
    @affected_count = @provider.appointments
                               .where(starts_at: Time.current..Time.current.end_of_day)
                               .where(status: [:scheduled, :checked_in])
                               .count
  end

  def create
    @provider = Provider.find(params[:provider_id])
    template = DelayWorkflowTemplate.find(params[:template_id])

    workflow = DelayWorkflowService.execute(
      template: template,
      provider: @provider,
      triggered_by: current_user,
      delay_minutes: params[:delay_minutes].to_i,
      gift_card_enabled: params[:gift_card_enabled] == "1"
    )

    if workflow
      redirect_to delay_workflow_path(workflow), notice: "Workflow triggered — #{workflow.affected_appointment_count} patients notified"
    else
      redirect_to provider_path(@provider), alert: "No affected appointments found"
    end
  end

  def show
    @workflow = DelayWorkflow.includes(delay_workflow_responses: [:patient, :appointment]).find(params[:id])
    @responses = @workflow.delay_workflow_responses.includes(:patient, :appointment).order("appointments.starts_at")
  end
end
