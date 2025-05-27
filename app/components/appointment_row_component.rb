class AppointmentRowComponent < ViewComponent::Base
  include ActionView::RecordIdentifier
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  LEFT_BAR_COLOR = {
    "scheduled" => "bg-gray-300 dark:bg-gray-600",
    "checked_in" => "bg-teal-500",
    "in_room" => "bg-blue-500",
    "running_late" => "bg-amber-500",
    "complete" => "bg-green-500",
    "no_show" => "bg-gray-400",
    "canceled" => "bg-gray-400"
  }.freeze

  def initialize(appointment:)
    @appointment = appointment
  end

  def call
    content_tag("turbo-frame", id: dom_id(@appointment)) do
      link_to(appointment_path(@appointment), class: "block group", data: { turbo_frame: "_top" }) do
        tag.div(class: row_classes, data: { controller: "appointment", appointment_id_value: @appointment.id }) do
          safe_join([left_bar, content_area])
        end
      end
    end
  end

  private

  def row_classes
    [
      "flex items-stretch rounded-2xl overflow-hidden transition",
      "bg-white dark:bg-gray-800/80",
      "border border-gray-200 dark:border-gray-700",
      "group-hover:border-teal-300 dark:group-hover:border-teal-700",
      "group-hover:shadow-lg"
    ].join(" ")
  end

  def left_bar
    color = LEFT_BAR_COLOR.fetch(@appointment.status, LEFT_BAR_COLOR["scheduled"])
    tag.div(class: "w-1.5 shrink-0 #{color}")
  end

  def content_area
    tag.div(class: "flex items-center gap-6 px-6 py-5 flex-1 min-w-0") do
      safe_join([time_column, details_column, right_section])
    end
  end

  def time_column
    tag.div(class: "shrink-0 w-20 text-right pr-2") do
      tag.time(datetime: @appointment.starts_at.iso8601) do
        safe_join([
          tag.span(@appointment.starts_at.strftime("%-l:%M"), class: "text-lg font-bold text-gray-900 dark:text-gray-100 tabular-nums"),
          tag.span(@appointment.starts_at.strftime(" %p"), class: "text-xs font-medium text-gray-400 dark:text-gray-500")
        ])
      end
    end
  end

  def details_column
    tag.div(class: "flex-1 min-w-0") do
      safe_join([
        tag.p(@appointment.patient.display_name, class: "text-sm font-semibold text-gray-900 dark:text-gray-100 truncate"),
        tag.p(provider_line, class: "text-xs text-gray-500 dark:text-gray-400 truncate mt-0.5")
      ])
    end
  end

  def provider_line
    line = @appointment.provider.display_name
    if @appointment.delay_minutes.to_i > 0
      line += " · +#{@appointment.delay_minutes} min"
    end
    line
  end

  def right_section
    tag.div(class: "shrink-0 flex items-center gap-3") do
      safe_join([
        render(StatusPillComponent.new(status: @appointment.status)),
        action_button
      ].compact)
    end
  end

  def action_button
    return unless actionable?

    if @appointment.scheduled?
      check_in_button
    elsif @appointment.checked_in? || @appointment.in_room?
      complete_button
    end
  end

  def check_in_button
    tag.button("Check In",
      class: "rounded-xl bg-teal-600 px-4 py-2 text-xs font-semibold text-white shadow-sm hover:bg-teal-500 active:bg-teal-700 min-h-[36px]",
      data: {
        action: "click->appointment#checkIn",
        appointment_target: "checkInButton"
      })
  end

  def complete_button
    tag.button("Done",
      class: "rounded-xl bg-green-600 px-4 py-2 text-xs font-semibold text-white shadow-sm hover:bg-green-500 active:bg-green-700 min-h-[36px]",
      data: {
        action: "click->appointment#complete",
        appointment_target: "completeButton"
      })
  end

  def actionable?
    @appointment.scheduled? || @appointment.checked_in? || @appointment.in_room?
  end
end
