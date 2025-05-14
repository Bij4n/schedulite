class AppointmentRowComponent < ViewComponent::Base
  include ActionView::RecordIdentifier

  def initialize(appointment:)
    @appointment = appointment
  end

  def call
    content_tag("turbo-frame", id: dom_id(@appointment)) do
      tag.div(class: "flex items-center gap-4 rounded-2xl bg-white px-4 py-4 shadow-sm ring-1 ring-gray-900/5 transition hover:shadow-md") do
        safe_join([time_column, details_column, status_column])
      end
    end
  end

  private

  def time_column
    tag.div(class: "shrink-0 text-center w-16") do
      tag.time(@appointment.starts_at.strftime("%-l:%M %p"),
        datetime: @appointment.starts_at.iso8601,
        class: "text-sm font-semibold text-gray-900")
    end
  end

  def details_column
    tag.div(class: "min-w-0 flex-1") do
      safe_join([
        tag.p(@appointment.patient.display_name, class: "text-sm font-medium text-gray-900 truncate"),
        tag.p(@appointment.provider.display_name, class: "text-xs text-gray-500 truncate")
      ])
    end
  end

  def status_column
    tag.div(class: "shrink-0") do
      render(StatusPillComponent.new(status: @appointment.status))
    end
  end
end
