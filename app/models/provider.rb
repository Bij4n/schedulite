class Provider < ApplicationRecord
  belongs_to :tenant
  has_many :appointments, dependent: :destroy
  has_many :patients, foreign_key: :primary_provider_id, dependent: :nullify

  acts_as_tenant :tenant

  validates :first_name, presence: true
  validates :last_name, presence: true

  def display_name
    "#{title.presence || 'Dr.'} #{last_name}"
  end
end
