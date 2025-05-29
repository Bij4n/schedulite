class Patient < ApplicationRecord
  belongs_to :tenant
  belongs_to :primary_provider, class_name: "Provider", optional: true
  has_many :appointments, dependent: :destroy
  has_many :sms_messages, dependent: :destroy

  acts_as_tenant :tenant

  audited except: %i[
    first_name_ciphertext last_name_ciphertext phone_ciphertext date_of_birth_ciphertext
    email_ciphertext phone_bidx date_of_birth_bidx email_bidx
  ]

  has_encrypted :first_name
  has_encrypted :last_name
  has_encrypted :phone
  has_encrypted :date_of_birth, type: :date
  has_encrypted :email

  blind_index :phone
  blind_index :date_of_birth
  blind_index :email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true

  def display_name
    "#{first_name} #{last_name[0]}."
  end
end
