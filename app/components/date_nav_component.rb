class DateNavComponent < ViewComponent::Base
  include ActionView::Helpers::UrlHelper

  def initialize(dates:, selected_date:, day_counts:, view_mode:)
    @dates = dates
    @selected_date = selected_date
    @day_counts = day_counts
    @view_mode = view_mode
  end

  def call
    tag.div(class: "border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800/50") do
      tag.div(class: "mx-auto max-w-3xl px-4 sm:px-6") do
        safe_join([week_nav, date_strip, view_toggle])
      end
    end
  end

  private

  def week_nav
    tag.div(class: "flex items-center justify-between py-2") do
      prev_week = @dates.first - 7.days
      next_week = @dates.first + 7.days

      safe_join([
        link_to(helpers.root_path(date: prev_week.iso8601, view: @view_mode), class: "p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300") do
          tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "2", stroke: "currentColor", class: "w-4 h-4") do
            tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M15.75 19.5L8.25 12l7.5-7.5")
          end
        end,
        tag.span(@dates.first.strftime("%B %Y"), class: "text-sm font-semibold text-gray-900 dark:text-gray-100"),
        link_to(helpers.root_path(date: next_week.iso8601, view: @view_mode), class: "p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300") do
          tag.svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke_width: "2", stroke: "currentColor", class: "w-4 h-4") do
            tag.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M8.25 4.5l7.5 7.5-7.5 7.5")
          end
        end
      ])
    end
  end

  def date_strip
    tag.div(class: "flex gap-1 pb-3 overflow-x-auto") do
      safe_join(@dates.map { |date| day_cell(date) })
    end
  end

  def day_cell(date)
    is_selected = date == @selected_date
    is_today = date == Date.current
    count = @day_counts[date] || 0

    base = "flex-1 min-w-[44px] rounded-xl px-2 py-2 text-center transition cursor-pointer"
    colors = if is_selected
      "bg-teal-600 text-white"
    elsif is_today
      "bg-teal-50 dark:bg-teal-900/20 text-teal-700 dark:text-teal-300"
    else
      "hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-600 dark:text-gray-400"
    end

    link_to(helpers.root_path(date: date.iso8601, view: @view_mode), class: "#{base} #{colors}") do
      safe_join([
        tag.div(date.strftime("%a"), class: "text-[10px] font-medium uppercase #{'text-teal-200' if is_selected}"),
        tag.div(date.day.to_s, class: "text-lg font-bold leading-tight"),
        count > 0 ? tag.div(count.to_s, class: "text-[10px] #{'text-teal-200' if is_selected}") : tag.div("", class: "text-[10px]")
      ])
    end
  end

  def view_toggle
    tag.div(class: "flex gap-1 pb-3") do
      safe_join([
        toggle_button("List", "list"),
        toggle_button("Week", "week")
      ])
    end
  end

  def toggle_button(label, mode)
    active = @view_mode == mode
    classes = if active
      "rounded-lg px-3 py-1 text-xs font-semibold bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900"
    else
      "rounded-lg px-3 py-1 text-xs font-medium text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700"
    end

    link_to(label, helpers.root_path(date: @selected_date.iso8601, view: mode), class: classes)
  end
end
