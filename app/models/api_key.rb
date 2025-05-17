class APIKey < ApplicationRecord
  belongs_to :tenant

  validates :name, presence: true

  attr_reader :raw_key

  before_create :generate_key

  def self.authenticate(raw_key)
    return nil if raw_key.blank?

    digest = Digest::SHA256.hexdigest(raw_key)
    key = find_by(key_digest: digest)
    key&.touch(:last_used_at)
    key
  end

  private

  def generate_key
    @raw_key = SecureRandom.hex(32)
    self.key_digest = Digest::SHA256.hexdigest(@raw_key)
  end
end
