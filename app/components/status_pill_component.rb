class StatusPillComponent < ViewComponent::Base
  STATUS_STYLES = {
    "scheduled" => "bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300",
    "checked_in" => "bg-teal-50 dark:bg-teal-900/30 text-teal-700 dark:text-teal-300",
    "in_room" => "bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300",
    "running_late" => "bg-amber-50 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300",
    "complete" => "bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300",
    "no_show" => "bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400",
    "canceled" => "bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400"
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
    tag.span(label,
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{styles}",
      role: "status",
      aria: { label: "Status: #{label}" })
  end

  private

  def styles
    STATUS_STYLES.fetch(@status, STATUS_STYLES["scheduled"])
  end

  def label
    STATUS_LABELS.fetch(@status, @status.humanize)
  end
end
