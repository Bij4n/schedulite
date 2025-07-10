class Location < ApplicationRecord
  belongs_to :tenant
  has_many :providers, dependent: :nullify
  has_many :appointments, dependent: :nullify

  acts_as_tenant :tenant

  validates :name, presence: true

  after_save :geocode_address, if: :address_fields_changed?

  def full_address
    [address, city, state, zip].compact.reject(&:blank?).join(", ")
  end

  private

  def geocode_address
    GeocodeAddressJob.perform_later("Location", id)
  end

  def address_fields_changed?
    saved_change_to_attribute?(:address) ||
      saved_change_to_attribute?(:city) ||
      saved_change_to_attribute?(:state) ||
      saved_change_to_attribute?(:zip)
  end
end
