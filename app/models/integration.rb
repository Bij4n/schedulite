class Integration < ApplicationRecord
  belongs_to :tenant

  acts_as_tenant :tenant

  has_encrypted :credentials, type: :json

  validates :adapter_type, presence: true
end
