class NavComponent < ViewComponent::Base
  NAV_ITEMS = [
    { label: "Today", path: :root_path, icon: "calendar" },
    { label: "Patients", path: :patients_path, icon: "users" },
    { label: "Providers", path: :providers_path, icon: "briefcase" },
    { label: "Settings", path: :settings_integrations_path, icon: "cog" }
  ].freeze

  def initialize(current_path:, current_user:)
    @current_path = current_path
    @current_user = current_user
  end

  def call
    safe_join([desktop_sidebar, mobile_bottom_bar])
  end

  private

  def desktop_sidebar
    tag.aside(class: "hidden sm:flex sm:flex-col sm:w-56 sm:fixed sm:inset-y-0 bg-white dark:bg-gray-800 border-r border-gray-100 dark:border-gray-700 z-20") do
      safe_join([brand_header, search_bar, nav_links(:desktop), user_footer])
    end
  end

  def mobile_bottom_bar
    tag.nav(class: "sm:hidden fixed bottom-0 inset-x-0 bg-white dark:bg-gray-800 border-t border-gray-100 dark:border-gray-700 z-20 safe-area-bottom",
            aria: { label: "Main navigation" }) do
      tag.div(class: "flex justify-around py-2") do
        safe_join(NAV_ITEMS.map { |item| mobile_tab(item) })
      end
    end
  end

  def brand_header
    tag.div(class: "px-4 py-5 border-b border-gray-100 dark:border-gray-700") do
      tag.h1("Schedulite", class: "text-lg font-bold text-teal-600")
    end
  end

  def search_bar
    tag.div(class: "px-3 py-3 border-b border-gray-100 dark:border-gray-700", data: { controller: "search" }) do
      safe_join([
        tag.div(class: "relative") do
          safe_join([
            tag.input(type: "text", placeholder: "Search patients...",
              class: "w-full rounded-xl border-0 bg-gray-100 dark:bg-gray-700 px-3 py-2 pl-9 text-sm text-gray-900 dark:text-gray-100 placeholder:text-gray-400 focus:ring-2 focus:ring-teal-600",
              data: { search_target: "input", action: "input->search#search blur->search#close" }),
            tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor",
              class: "w-4 h-4 text-gray-400 absolute left-3 top-2.5 pointer-events-none") do
              tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z")
            end
          ])
        end,
        tag.div(class: "hidden absolute left-3 right-3 mt-1 rounded-xl bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 shadow-lg overflow-hidden z-30 max-h-64 overflow-y-auto",
          data: { search_target: "results" })
      ])
    end
  end

  def nav_links(variant)
    tag.nav(class: "flex-1 px-3 py-4 space-y-1", aria: { label: "Main navigation" }) do
      safe_join(NAV_ITEMS.map { |item| desktop_link(item) })
    end
  end

  def desktop_link(item)
    path = helpers.send(item[:path])
    active = @current_path.start_with?(path == "/" ? path : path)
    active = @current_path == "/" if path == "/"

    classes = if active
      "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300"
    else
      "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-700"
    end

    link_to(path, class: classes) do
      safe_join([icon_svg(item[:icon]), item[:label]])
    end
  end

  def mobile_tab(item)
    path = helpers.send(item[:path])
    active = @current_path.start_with?(path == "/" ? path : path)
    active = @current_path == "/" if path == "/"

    color = active ? "text-teal-600" : "text-gray-400"

    link_to(path, class: "flex flex-col items-center gap-0.5 px-3 py-1 min-w-[44px] min-h-[44px] #{color}") do
      safe_join([
        icon_svg(item[:icon], size: "w-5 h-5"),
        tag.span(item[:label], class: "text-[10px] font-medium")
      ])
    end
  end

  def user_footer
    tag.div(class: "px-4 py-3 border-t border-gray-100 dark:border-gray-700") do
      safe_join([
        link_to(helpers.settings_profile_path, class: "block hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg -mx-1 px-1 py-1") do
          safe_join([
            tag.p(@current_user.full_name, class: "text-sm font-medium text-gray-900 dark:text-gray-100 truncate"),
            tag.p(@current_user.role.humanize, class: "text-xs text-gray-500 dark:text-gray-400")
          ])
        end,
        link_to("Sign out", helpers.destroy_user_session_path,
          data: { turbo_method: :delete },
          class: "mt-2 text-xs text-teal-600 hover:text-teal-500")
      ])
    end
  end

  def icon_svg(name, size: "w-5 h-5")
    case name
    when "calendar"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: size) do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 11.25v7.5")
      end
    when "users"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: size) do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z")
      end
    when "briefcase"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: size) do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M20.25 14.15v4.25c0 1.094-.787 2.036-1.872 2.18-2.087.277-4.216.42-6.378.42s-4.291-.143-6.378-.42c-1.085-.144-1.872-1.086-1.872-2.18v-4.25m16.5 0a2.18 2.18 0 00.75-1.661V8.706c0-1.081-.768-2.015-1.837-2.175a48.114 48.114 0 00-3.413-.387m4.5 8.006c-.194.165-.42.295-.673.38A23.978 23.978 0 0112 15.75c-2.648 0-5.195-.429-7.577-1.22a2.016 2.016 0 01-.673-.38m0 0A2.18 2.18 0 013 12.489V8.706c0-1.081.768-2.015 1.837-2.175a48.111 48.111 0 013.413-.387m7.5 0V5.25A2.25 2.25 0 0013.5 3h-3a2.25 2.25 0 00-2.25 2.25v.894m7.5 0a48.667 48.667 0 00-7.5 0M12 12.75h.008v.008H12v-.008z")
      end
    when "cog"
      tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: size) do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z")
      end
    end
  end
end
