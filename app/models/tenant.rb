class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :name, presence: true
  validates :subdomain,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { minimum: 3, maximum: 63 },
    format: { with: /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?\z/, message: "must be lowercase alphanumeric with optional hyphens" }

  before_validation :normalize_subdomain

  private

  def normalize_subdomain
    self.subdomain = subdomain&.downcase&.strip
  end
end
