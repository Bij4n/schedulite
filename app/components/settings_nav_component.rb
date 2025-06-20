class SettingsNavComponent < ViewComponent::Base
  ITEMS = [
    { label: "Practice", path: :settings_practice_path, admin_only: true },
    { label: "Team", path: :settings_staff_index_path, admin_only: true },
    { label: "Integrations", path: :settings_integrations_path, admin_only: true },
    { label: "Workflows", path: :settings_workflow_templates_path, admin_only: true },
    { label: "Analytics", path: :settings_analytics_path, admin_only: true },
    :divider,
    { label: "Profile", path: :settings_profile_path, admin_only: false }
  ].freeze

  def initialize(current_path:, current_user: nil)
    @current_path = current_path
    @current_user = current_user
  end

  def call
    tag.div(class: "w-full") do
      safe_join([desktop_sidebar, mobile_nav])
    end
  end

  private

  def desktop_sidebar
    tag.nav(class: "hidden sm:block space-y-0.5", aria: { label: "Settings" }) do
      safe_join(visible_items.map { |item| item == :divider ? divider : sidebar_link(item) })
    end
  end

  def mobile_nav
    tag.nav(class: "sm:hidden flex gap-1 overflow-x-auto pb-3 px-4", aria: { label: "Settings" }) do
      safe_join(visible_items.reject { |i| i == :divider }.map { |item| mobile_tab(item) })
    end
  end

  def sidebar_link(item)
    path = helpers.send(item[:path])
    active = active?(path)

    classes = if active
      "flex items-center rounded-xl px-3 py-2.5 text-sm font-medium bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300"
    else
      "flex items-center rounded-xl px-3 py-2.5 text-sm font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700/50 transition"
    end

    link_to(item[:label], path, class: classes)
  end

  def mobile_tab(item)
    path = helpers.send(item[:path])
    active = active?(path)

    classes = if active
      "rounded-lg px-3 py-1.5 text-xs font-medium bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300 whitespace-nowrap"
    else
      "rounded-lg px-3 py-1.5 text-xs font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 whitespace-nowrap"
    end

    link_to(item[:label], path, class: classes)
  end

  def divider
    tag.div(class: "my-2 border-t border-gray-100 dark:border-gray-700")
  end

  def active?(path)
    if path == helpers.settings_staff_index_path
      @current_path.start_with?("/settings/staff") || @current_path.start_with?("/settings/timesheet") || @current_path.start_with?("/settings/time_off")
    elsif path == helpers.settings_integrations_path
      @current_path.start_with?("/settings/integrations") || @current_path.start_with?("/settings/sync_health")
    else
      @current_path.start_with?(path)
    end
  end

  def visible_items
    ITEMS.select { |item| item == :divider || !item[:admin_only] || admin? }
  end

  def admin?
    @current_user&.owner? || @current_user&.manager?
  end
end
