class DailyDigestJob < ApplicationJob
  queue_as :default

  def perform
    User.where(role: :owner).find_each do |owner|
      AppointmentMailer.daily_digest(owner).deliver_later
    end
  end
end
