class PatientFeedback < ApplicationRecord
  belongs_to :appointment
  belongs_to :patient

  validates :rating, presence: true, inclusion: { in: 1..5 }

  def self.average_rating
    average(:rating)&.to_f&.round(1) || 0
  end
end
