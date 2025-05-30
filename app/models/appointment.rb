class Appointment < ApplicationRecord
  belongs_to :tenant
  belongs_to :provider
  belongs_to :patient
  has_many :status_events, dependent: :destroy
  has_many :sms_messages, dependent: :destroy
  has_many :gift_cards, dependent: :destroy
  has_many :no_show_charges, dependent: :destroy

  acts_as_tenant :tenant

  audited except: %i[notes_ciphertext]

  has_encrypted :notes

  enum :status, {
    scheduled: 0,
    checked_in: 1,
    in_room: 2,
    running_late: 3,
    complete: 4,
    no_show: 5,
    canceled: 6
  }, default: :scheduled

  validates :starts_at, presence: true
  validates :status, presence: true

  before_create :generate_signed_token

  after_update_commit :broadcast_update, if: :saved_change_to_status?

  scope :today, -> { where(starts_at: Time.current.all_day) }
  scope :chronological, -> { order(:starts_at) }

  def broadcast_update
    broadcast_replace_to(
      "tenant_#{tenant_id}_appointments",
      target: "appointment_#{id}",
      partial: "appointments/appointment_row",
      locals: { appointment: self }
    )

    broadcast_replace_to(
      "appointment_status_#{signed_token}",
      target: "status_card",
      partial: "patient_status/status_card",
      locals: { appointment: self }
    )
  end

  private

  def generate_signed_token
    self.signed_token ||= SecureRandom.urlsafe_base64(32)
  end
end
