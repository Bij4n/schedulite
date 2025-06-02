class User < ApplicationRecord
  belongs_to :tenant
  has_many :staff_shifts, dependent: :destroy
  has_many :time_entries, dependent: :destroy
  has_many :time_off_requests, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :timeoutable

  enum :role, { owner: 0, admin: 1, front_desk: 2, provider: 3 }, default: :front_desk

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def timeout_in
    15.minutes
  end
end
