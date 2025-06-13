class User < ApplicationRecord
  belongs_to :tenant
  has_many :staff_shifts, dependent: :destroy
  has_many :time_entries, dependent: :destroy
  has_many :time_off_requests, dependent: :destroy
  has_many :integrations, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :timeoutable

  enum :role, { owner: 0, manager: 1, staff: 2, provider: 3 }, default: :staff

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def timeout_in
    15.minutes
  end

  # Permission helpers
  def owner_or_manager?
    owner? || manager?
  end

  def can_manage_staff?
    owner? || manager?
  end

  def can_manage_settings?
    owner?
  end

  def can_view_timesheet?
    owner? || manager?
  end

  def can_approve_time_off?
    owner? || manager?
  end

  def can_manage_integrations?
    owner? || manager?
  end

  def can_view_analytics?
    owner? || manager?
  end
end
