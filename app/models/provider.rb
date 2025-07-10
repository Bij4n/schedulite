class Provider < ApplicationRecord
  belongs_to :tenant
  belongs_to :location, optional: true
  has_many :appointments, dependent: :destroy
  has_many :patients, foreign_key: :primary_provider_id, dependent: :nullify
  has_many :integrations, dependent: :destroy
  has_many :provider_schedules, dependent: :destroy

  acts_as_tenant :tenant

  validates :first_name, presence: true
  validates :last_name, presence: true

  def display_name
    "#{title.presence || 'Dr.'} #{last_name}"
  end

  def calendar_integration
    integrations.first
  end

  def calendar_connected?
    integrations.any?
  end
end
