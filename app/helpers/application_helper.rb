module ApplicationHelper
  def status_bg(status)
    case status.to_s
    when "scheduled" then "bg-gray-50 dark:bg-gray-700/50"
    when "checked_in" then "bg-teal-50 dark:bg-teal-900/20"
    when "in_room" then "bg-blue-50 dark:bg-blue-900/20"
    when "running_late" then "bg-amber-50 dark:bg-amber-900/20"
    when "complete" then "bg-green-50 dark:bg-green-900/20"
    when "no_show", "canceled" then "bg-gray-50 dark:bg-gray-700/30"
    else "bg-gray-50 dark:bg-gray-700/50"
    end
  end

  def format_phone(phone)
    return phone unless phone.present?
    digits = phone.gsub(/\D/, "")
    case digits.length
    when 10 then "+1 (#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}"
    when 11 then "+#{digits[0]} (#{digits[1..3]}) #{digits[4..6]}-#{digits[7..10]}"
    else phone
    end
  end

  def render_integration_card(avail, recommended: false)
    already_connected = @integrations&.any? { |i| i.adapter_type == avail[:type] }

    content_tag(:div, class: "rounded-2xl bg-white dark:bg-gray-800 p-4 border border-gray-200 dark:border-gray-700 hover:border-teal-300 dark:hover:border-teal-700 transition") do
      safe_join([
        content_tag(:div, class: "flex items-start justify-between") do
          safe_join([
            content_tag(:div, class: "min-w-0") do
              safe_join([
                content_tag(:div, class: "flex items-center gap-2") do
                  name = content_tag(:h3, avail[:name], class: "text-sm font-semibold text-gray-900 dark:text-gray-100")
                  badge = recommended ? content_tag(:span, "Recommended", class: "text-[10px] font-medium rounded-full px-1.5 py-0.5 bg-teal-50 dark:bg-teal-900/20 text-teal-600 dark:text-teal-400") : nil
                  safe_join([name, badge].compact)
                end,
                content_tag(:p, avail[:description], class: "text-xs text-gray-500 dark:text-gray-400 mt-1")
              ])
            end,
            if already_connected
              content_tag(:span, "Connected", class: "text-xs text-teal-600 font-medium shrink-0 ml-3")
            else
              link_to("Connect", new_settings_integration_path(type: avail[:type]),
                class: "shrink-0 ml-3 rounded-xl bg-teal-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-teal-500")
            end
          ])
        end
      ])
    end
  end
end
