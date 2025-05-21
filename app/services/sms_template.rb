class SmsTemplate
  PHI_FIELDS = %w[last_name dob date_of_birth diagnosis reason provider_specialty].freeze

  TEMPLATES = {
    check_in_confirmation: "Hi %{first_name}, you're checked in for your %{appointment_time} appointment. We'll text you with any updates. Track your status: %{status_url}",
    delay_notice: "Hi %{first_name}, your provider is running about %{delay_minutes} min behind schedule. We'll text you when you're up next. Status: %{status_url}",
    youre_next: "Hi %{first_name}, you're next! Please head to the front desk. We'll see you shortly.",
    gift_card_issued: "Hi %{first_name}, we're sorry for the wait. Here's a small thank-you: %{gift_card_url}",
    reminder_24h: "Hi %{first_name}, reminder: you have an appointment tomorrow at %{appointment_time}. Reply STOP to opt out of texts.",
    reminder_2h: "Hi %{first_name}, your %{appointment_time} appointment is coming up in about 2 hours. See you soon!"
  }.freeze

  class PhiLeakError < StandardError; end

  def self.render(template_name, variables)
    template = TEMPLATES.fetch(template_name)
    template % variables
  end

  def self.lint!
    TEMPLATES.each do |name, template|
      PHI_FIELDS.each do |field|
        if template.include?("%{#{field}}")
          raise PhiLeakError, "SMS template :#{name} contains PHI field '#{field}'"
        end
      end
    end
    true
  end
end
