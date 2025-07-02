class TimeOffMailer < ApplicationMailer
  def request_submitted(requester:, manager:, start_date:, end_date:, reason: nil)
    @requester = requester
    @manager = manager
    @start_date = start_date
    @end_date = end_date
    @reason = reason

    mail(
      to: manager.email,
      subject: "Time Off Request — #{requester.full_name}"
    )
  end
end
