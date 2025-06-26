class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :providers, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :gift_cards, dependent: :destroy
  has_one :gift_card_settings, dependent: :destroy

  validates :name, presence: true
  validates :subdomain,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { minimum: 3, maximum: 63 },
    format: { with: /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?\z/, message: "must be lowercase alphanumeric with optional hyphens" }

  before_validation :normalize_subdomain
  after_save :geocode_address, if: :address_fields_changed?

  def full_address
    [address, city, state, zip].compact.reject(&:blank?).join(", ")
  end

  private

  def normalize_subdomain
    self.subdomain = subdomain&.downcase&.strip
  end

  def geocode_address
    GeocodeAddressJob.perform_later("Tenant", id)
  end

  def address_fields_changed?
    saved_change_to_attribute?(:address) ||
      saved_change_to_attribute?(:city) ||
      saved_change_to_attribute?(:state) ||
      saved_change_to_attribute?(:zip)
  end
end
