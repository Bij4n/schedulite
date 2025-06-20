class DelayWorkflowTemplate < ApplicationRecord
  belongs_to :tenant
  has_many :delay_workflows, foreign_key: :template_id, dependent: :destroy

  acts_as_tenant :tenant

  validates :name, presence: true
  validates :message_body, presence: true

  def render_message(variables = {})
    message_body % variables
  rescue KeyError => e
    message_body
  end

  def response_options
    options = []
    options << "Reply 1 to keep your appointment and wait"
    options << "Reply 2 to reschedule" if offer_reschedule?
    options << "Reply 3 to cancel" if offer_cancel?
    options.join(". ") + "."
  end
end
