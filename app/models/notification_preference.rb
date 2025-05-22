class NotificationPreference < ApplicationRecord
  belongs_to :tenant

  validates :event_name, presence: true, uniqueness: { scope: :tenant_id }

  def self.sms_enabled_for?(tenant:, event:)
    pref = find_by(tenant: tenant, event_name: event)
    return true unless pref # default to enabled
    pref.sms_enabled?
  end

  def self.email_enabled_for?(tenant:, event:)
    pref = find_by(tenant: tenant, event_name: event)
    return false unless pref # default to disabled
    pref.email_enabled?
  end
end
