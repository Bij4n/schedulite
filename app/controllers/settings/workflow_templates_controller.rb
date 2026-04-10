module Settings
  class WorkflowTemplatesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @templates = DelayWorkflowTemplate.all
    end

    def new
      @template = DelayWorkflowTemplate.new(
        offer_reschedule: true,
        offer_cancel: true,
        offer_gift_card: false,
        message_body: "Hi, %{provider_name} is running about %{delay_minutes} minutes behind schedule. Your appointment was at %{original_time} and is now estimated for %{new_time}."
      )
    end

    def create
      @template = DelayWorkflowTemplate.new(template_params)

      if @template.save
        redirect_to settings_workflow_templates_path, notice: "Template created"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      template = DelayWorkflowTemplate.find(params[:id])
      template.destroy!
      redirect_to settings_workflow_templates_path, notice: "Template removed"
    end

    private

    def template_params
      params.require(:delay_workflow_template).permit(:name, :message_body, :offer_reschedule, :offer_cancel, :offer_gift_card, :response_instructions)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.owner_or_manager?
    end
  end
end
