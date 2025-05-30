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

  blind_index :phone
  blind_index :date_of_birth
  blind_index :email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true

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
end
