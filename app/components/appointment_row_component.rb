class AppointmentRowComponent < ViewComponent::Base
  include ActionView::RecordIdentifier
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  def initialize(appointment:)
    @appointment = appointment
  end

  def call
    content_tag("turbo-frame", id: dom_id(@appointment)) do
      tag.div(class: row_classes, data: { controller: "appointment", appointment_id_value: @appointment.id }) do
        safe_join([time_column, details_column, status_column, action_column].compact)
      end
    end
  end

  private

  def row_classes
    "flex items-center gap-4 rounded-2xl bg-white dark:bg-gray-800 px-4 py-4 shadow-sm ring-1 ring-gray-900/5 dark:ring-gray-700 transition hover:shadow-md"
  end

  def time_column
    tag.div(class: "shrink-0 text-center w-16") do
      tag.time(@appointment.starts_at.strftime("%-l:%M %p"),
        datetime: @appointment.starts_at.iso8601,
        class: "text-sm font-semibold text-gray-900 dark:text-gray-100")
    end
  end

  def details_column
    link_to(appointment_path(@appointment), class: "min-w-0 flex-1 block", data: { turbo_frame: "_top" }) do
      safe_join([
        tag.p(@appointment.patient.display_name, class: "text-sm font-medium text-gray-900 dark:text-gray-100 truncate"),
        tag.p(provider_line, class: "text-xs text-gray-500 dark:text-gray-400 truncate")
      ])
    end
  end

  def provider_line
    line = @appointment.provider.display_name
    if @appointment.delay_minutes.to_i > 0
      line += " (+#{@appointment.delay_minutes}min)"
    end
    line
  end

  def status_column
    tag.div(class: "shrink-0") do
      render(StatusPillComponent.new(status: @appointment.status))
    end
  end

  def action_column
    return unless actionable?

    tag.div(class: "shrink-0") do
      if @appointment.scheduled?
        check_in_button
      elsif @appointment.checked_in? || @appointment.in_room?
        complete_button
      end
    end
  end

  def check_in_button
    tag.button("Check In",
      class: "rounded-xl bg-teal-600 px-3 py-1.5 text-xs font-semibold text-white shadow-sm hover:bg-teal-500 active:bg-teal-700",
      data: {
        action: "click->appointment#checkIn",
        appointment_target: "checkInButton"
      })
  end

  def complete_button
    tag.button("Complete",
      class: "rounded-xl bg-green-600 px-3 py-1.5 text-xs font-semibold text-white shadow-sm hover:bg-green-500 active:bg-green-700",
      data: {
        action: "click->appointment#complete",
        appointment_target: "completeButton"
      })
  end

  def actionable?
    @appointment.scheduled? || @appointment.checked_in? || @appointment.in_room?
  end
end
