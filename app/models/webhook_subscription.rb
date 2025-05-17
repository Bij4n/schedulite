class WebhookSubscription < ApplicationRecord
  belongs_to :tenant

  validates :url, presence: true
  validates :events, presence: true

  attr_writer :secret

  before_create :digest_secret

  def matches_event?(event_name)
    events.split(",").map(&:strip).include?(event_name)
  end

  def compute_signature(body)
    OpenSSL::HMAC.hexdigest("SHA256", secret_digest, body)
  end

  private

  def digest_secret
    raw = @secret || SecureRandom.hex(32)
    self.secret_digest = Digest::SHA256.hexdigest(raw)
  end
end
