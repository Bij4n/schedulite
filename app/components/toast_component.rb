class ToastComponent < ViewComponent::Base
  VARIANTS = {
    success: { bg: "bg-teal-50", text: "text-teal-800", icon_color: "text-teal-600" },
    error: { bg: "bg-red-50", text: "text-red-800", icon_color: "text-red-600" },
    info: { bg: "bg-blue-50", text: "text-blue-800", icon_color: "text-blue-600" }
  }.freeze

  def initialize(message:, variant: :success)
    @message = message
    @variant = variant.to_sym
  end

  def call
    tag.div(
      class: "fixed top-4 right-4 z-50 rounded-2xl px-5 py-3 shadow-md #{styles[:bg]} #{styles[:text]}",
      data: { controller: "toast", toast_auto_dismiss_value: true },
      role: "alert",
      aria: { live: "polite" }
    ) do
      tag.p(@message, class: "text-sm font-medium")
    end
  end

  private

  def styles
    VARIANTS.fetch(@variant, VARIANTS[:info])
  end
end
