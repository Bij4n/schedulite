Rails.application.config.after_initialize do
  SmsTemplate.lint!
end
