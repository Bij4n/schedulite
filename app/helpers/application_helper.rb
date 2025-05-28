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
end
