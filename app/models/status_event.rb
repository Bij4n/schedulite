class StatusEvent < ApplicationRecord
  belongs_to :appointment
  belongs_to :user, optional: true

  validates :to_status, presence: true
end
