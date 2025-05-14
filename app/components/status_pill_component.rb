class StatusPillComponent < ViewComponent::Base
  STATUS_STYLES = {
    "scheduled" => "bg-gray-100 text-gray-700",
    "checked_in" => "bg-teal-50 text-teal-700",
    "in_room" => "bg-blue-50 text-blue-700",
    "running_late" => "bg-amber-50 text-amber-700",
    "complete" => "bg-green-50 text-green-700",
    "no_show" => "bg-gray-100 text-gray-500",
    "canceled" => "bg-gray-100 text-gray-500"
  }.freeze

  STATUS_LABELS = {
    "scheduled" => "Scheduled",
    "checked_in" => "Checked In",
    "in_room" => "In Room",
    "running_late" => "Running Late",
    "complete" => "Complete",
    "no_show" => "No Show",
    "canceled" => "Canceled"
  }.freeze

  def initialize(status:)
    @status = status.to_s
  end

  def call
    tag.span(label, class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{styles}")
  end

  private

  def styles
    STATUS_STYLES.fetch(@status, STATUS_STYLES["scheduled"])
  end

  def label
    STATUS_LABELS.fetch(@status, @status.humanize)
  end
end
