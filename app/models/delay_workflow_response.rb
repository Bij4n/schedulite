class DelayWorkflowResponse < ApplicationRecord
  belongs_to :delay_workflow
  belongs_to :appointment
  belongs_to :patient

  validates :response, inclusion: { in: %w[no_response waiting rescheduling canceling] }

  def responded?
    response != "no_response"
  end
end
