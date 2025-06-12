class SettingsNavComponent < ViewComponent::Base
  GROUPS = [
    {
      label: "General",
      items: [
        { label: "Practice", path: :settings_practice_path, admin_only: true, icon: "building" },
        { label: "Profile", path: :settings_profile_path, admin_only: false, icon: "user" }
      ]
    },
    {
      label: "Team",
      items: [
        { label: "Staff", path: :settings_staff_index_path, admin_only: true, icon: "users" },
        { label: "Timesheet", path: :settings_timesheet_path, admin_only: true, icon: "clock" },
        { label: "Time Off", path: :settings_time_off_path, admin_only: true, icon: "calendar-off" }
      ]
    },
    {
      label: "Connections",
      items: [
        { label: "Integrations", path: :settings_integrations_path, admin_only: true, icon: "plug" },
        { label: "Sync Health", path: :settings_sync_health_path, admin_only: true, icon: "pulse" }
      ]
    },
    {
      label: "Reports",
      items: [
        { label: "Analytics", path: :settings_analytics_path, admin_only: true, icon: "chart" }
      ]
    }
  ].freeze

  def initialize(current_path:, current_user: nil)
    @current_path = current_path
    @current_user = current_user
  end

  def call
    tag.div(class: "mx-auto max-w-3xl px-4 sm:px-6 pt-4 pb-2") do
      safe_join([mobile_nav, desktop_nav])
    end
  end

  private

  def mobile_nav
    # Compact horizontal scroll on mobile — show only flat list
    tag.nav(class: "sm:hidden flex gap-1 overflow-x-auto pb-2 -mx-1 px-1", aria: { label: "Settings" }) do
      safe_join(flat_items.map { |item| mobile_tab(item) })
    end
  end

  def desktop_nav
    # Grouped vertical sidebar on desktop
    tag.nav(class: "hidden sm:flex gap-6 pb-2", aria: { label: "Settings" }) do
      safe_join(visible_groups.map { |group| group_section(group) })
    end
  end

  def group_section(group)
    tag.div(class: "flex items-center gap-1") do
      safe_join([
        tag.span(group[:label], class: "text-[10px] font-bold text-gray-300 dark:text-gray-600 uppercase tracking-widest mr-1"),
        *group[:items].select { |i| visible?(i) }.map { |item| desktop_tab(item) }
      ])
    end
  end

  def desktop_tab(item)
    path = helpers.send(item[:path])
    active = @current_path.start_with?(path)

    classes = if active
      "rounded-lg px-2.5 py-1.5 text-sm font-medium bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300"
    else
      "rounded-lg px-2.5 py-1.5 text-sm font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700"
    end

    link_to(item[:label], path, class: classes)
  end

  def mobile_tab(item)
    path = helpers.send(item[:path])
    active = @current_path.start_with?(path)

    classes = if active
      "rounded-lg px-3 py-1.5 text-xs font-medium bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300 whitespace-nowrap"
    else
      "rounded-lg px-3 py-1.5 text-xs font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 whitespace-nowrap"
    end

    link_to(item[:label], path, class: classes)
  end

  def flat_items
    GROUPS.flat_map { |g| g[:items] }.select { |i| visible?(i) }
  end

  def visible_groups
    GROUPS.select { |g| g[:items].any? { |i| visible?(i) } }
  end

  def visible?(item)
    !item[:admin_only] || admin?
  end

  def admin?
    @current_user&.owner? || @current_user&.admin?
  end
end
