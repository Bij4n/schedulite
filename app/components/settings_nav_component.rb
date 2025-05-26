class SettingsNavComponent < ViewComponent::Base
  ITEMS = [
    { label: "Integrations", path: :settings_integrations_path },
    { label: "Staff", path: :settings_staff_index_path },
    { label: "Analytics", path: :settings_analytics_path },
    { label: "Profile", path: :settings_profile_path }
  ].freeze

  def initialize(current_path:)
    @current_path = current_path
  end

  def call
    tag.div(class: "mx-auto max-w-2xl px-4 sm:px-6 pt-4 pb-2") do
      tag.nav(class: "flex gap-1 overflow-x-auto", aria: { label: "Settings" }) do
        safe_join(ITEMS.map { |item| tab(item) })
      end
    end
  end

  private

  def tab(item)
    path = helpers.send(item[:path])
    active = @current_path.start_with?(path)

    classes = if active
      "rounded-lg px-3 py-1.5 text-sm font-medium bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300 whitespace-nowrap"
    else
      "rounded-lg px-3 py-1.5 text-sm font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 whitespace-nowrap"
    end

    link_to(item[:label], path, class: classes)
  end
end
