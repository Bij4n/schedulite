class LoginEvent < ApplicationRecord
  belongs_to :user, optional: true

  validates :event_type, presence: true, inclusion: { in: %w[sign_in sign_in_failed sign_out] }

  scope :recent, -> { order(created_at: :desc) }

  def self.record_sign_in(user, request)
    create!(user: user, event_type: "sign_in", ip_address: request.remote_ip, user_agent: request.user_agent)
  end

  def self.record_failed_sign_in(email, request)
    create!(event_type: "sign_in_failed", ip_address: request.remote_ip, user_agent: request.user_agent)
  end

  def self.record_sign_out(user, request)
    create!(user: user, event_type: "sign_out", ip_address: request.remote_ip, user_agent: request.user_agent)
  end
end
