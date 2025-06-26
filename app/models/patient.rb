class Patient < ApplicationRecord
  belongs_to :tenant
  belongs_to :primary_provider, class_name: "Provider", optional: true
  has_many :appointments, dependent: :destroy
  has_many :sms_messages, dependent: :destroy
  has_many :no_show_charges, dependent: :destroy

  acts_as_tenant :tenant

  audited except: %i[
    first_name_ciphertext last_name_ciphertext phone_ciphertext date_of_birth_ciphertext
    email_ciphertext stripe_customer_id_ciphertext stripe_payment_method_id_ciphertext
    phone_bidx date_of_birth_bidx email_bidx
  ]

  has_encrypted :first_name
  has_encrypted :last_name
  has_encrypted :phone
  has_encrypted :date_of_birth, type: :date
  has_encrypted :email
  has_encrypted :stripe_customer_id
  has_encrypted :stripe_payment_method_id
  has_encrypted :address

  blind_index :phone
  blind_index :date_of_birth
  blind_index :email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true

  after_save :geocode_address, if: :address_changed?

  def display_name
    "#{first_name} #{last_name[0]}."
  end

  def card_on_file?
    card_last4.present?
  end

  def card_display
    return nil unless card_on_file?
    "#{card_brand&.capitalize} ending in #{card_last4}"
  end

  def has_address?
    latitude.present? && longitude.present?
  end

  def full_address
    [address, city, state, zip].compact.reject(&:blank?).join(", ")
  end

  def estimated_travel_minutes(to_lat:, to_lng:)
    return nil unless has_address? && to_lat && to_lng

    RoutingService.driving_time(
      from_lat: latitude, from_lng: longitude,
      to_lat: to_lat, to_lng: to_lng
    )
  end

  private

  def geocode_address
    GeocodeAddressJob.perform_later("Patient", id)
  end

  def address_changed?
    saved_change_to_attribute?(:address_ciphertext)
  end
end
