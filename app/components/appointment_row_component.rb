class AppointmentRowComponent < ViewComponent::Base
  include ActionView::RecordIdentifier
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  STATUS_LEFT_BORDER = {
    "scheduled" => "border-l-gray-300 dark:border-l-gray-600",
    "checked_in" => "border-l-teal-500",
    "in_room" => "border-l-blue-500",
    "running_late" => "border-l-amber-500",
    "complete" => "border-l-green-500",
    "no_show" => "border-l-gray-400",
    "canceled" => "border-l-gray-400"
  }.freeze

  def initialize(appointment:)
    @appointment = appointment
  end

  def call
    content_tag("turbo-frame", id: dom_id(@appointment)) do
      link_to(appointment_path(@appointment), class: "block group", data: { turbo_frame: "_top" }) do
        tag.div(class: row_classes, data: { controller: "appointment", appointment_id_value: @appointment.id }) do
          safe_join([left_accent, content_area])
        end
      end
    end
  end

  private

  def row_classes
    "flex items-stretch rounded-2xl bg-white dark:bg-gray-800 shadow-sm ring-1 ring-gray-900/5 dark:ring-gray-700 overflow-hidden transition group-hover:shadow-md group-hover:ring-teal-200 dark:group-hover:ring-teal-800"
  end

  def left_accent
    border_color = STATUS_LEFT_BORDER.fetch(@appointment.status, STATUS_LEFT_BORDER["scheduled"])
    tag.div(class: "w-1 shrink-0 #{border_color} bg-current opacity-60")
  end

  def content_area
    tag.div(class: "flex items-center gap-5 px-5 py-4 flex-1 min-w-0") do
      safe_join([time_column, details_column, right_section])
    end
  end

  def time_column
    tag.div(class: "shrink-0 w-14") do
      tag.time(datetime: @appointment.starts_at.iso8601, class: "block") do
        safe_join([
          tag.span(@appointment.starts_at.strftime("%-l:%M"), class: "text-base font-bold text-gray-900 dark:text-gray-100 tabular-nums"),
          tag.span(" " + @appointment.starts_at.strftime("%p"), class: "text-[10px] font-medium text-gray-400 dark:text-gray-500 uppercase")
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
