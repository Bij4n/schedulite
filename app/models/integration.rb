class Integration < ApplicationRecord
  belongs_to :tenant
  belongs_to :provider, optional: true
  belongs_to :user, optional: true

  acts_as_tenant :tenant

  has_encrypted :credentials, type: :json

  validates :adapter_type, presence: true

  scope :healthy, -> { where(sync_error: nil) }
  scope :errored, -> { where.not(sync_error: nil) }

  def sync_status
    if sync_error.present? && sync_error_at.present? && sync_error_at > 24.hours.ago
      :error
    elsif last_synced_at.nil? || last_synced_at < 24.hours.ago
      :stale
    else
      :healthy
    end
  end

  def record_sync_error!(message)
    update!(sync_error: message, sync_error_at: Time.current)
  end

  def clear_sync_error!
    update!(sync_error: nil, sync_error_at: nil, last_synced_at: Time.current)
  end

  def display_name
    if provider
      "#{provider.display_name} — #{adapter_type.humanize}"
    elsif user
      "#{user.full_name} — #{adapter_type.humanize}"
    else
      "Practice-wide — #{adapter_type.humanize}"
    end
  end
end
