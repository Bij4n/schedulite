class DelayButtonComponent < ViewComponent::Base
  DELAY_OPTIONS = [5, 10, 15, 30].freeze

  def initialize(appointment:)
    @appointment = appointment
  end

  def call
    tag.div(class: "flex gap-2", data: { controller: "delay", delay_appointment_id_value: @appointment.id }) do
      safe_join(DELAY_OPTIONS.map { |minutes| delay_button(minutes) })
    end
  end

  private

  def delay_button(minutes)
    tag.button("+#{minutes}",
      class: "rounded-xl bg-amber-100 px-3 py-2 text-sm font-semibold text-amber-800 hover:bg-amber-200 active:bg-amber-300 min-w-[44px] min-h-[44px]",
      data: {
        action: "click->delay#setDelay",
        delay_minutes_param: minutes
      })
  end
end
