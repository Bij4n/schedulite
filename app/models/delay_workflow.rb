class DelayWorkflow < ApplicationRecord
  belongs_to :tenant
  belongs_to :provider
  belongs_to :triggered_by, class_name: "User"
  belongs_to :template, class_name: "DelayWorkflowTemplate"
  has_many :delay_workflow_responses, dependent: :destroy

  validates :delay_minutes, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[active completed] }

  scope :active, -> { where(status: "active") }

  def waiting_count
    delay_workflow_responses.where(response: "waiting").count
  end

  def rescheduling_count
    delay_workflow_responses.where(response: "rescheduling").count
  end

  def canceling_count
    delay_workflow_responses.where(response: "canceling").count
  end

  def no_response_count
    delay_workflow_responses.where(response: "no_response").count
  end

  def complete!
    update!(status: "completed")
  end
end
