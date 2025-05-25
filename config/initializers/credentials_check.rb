Rails.application.config.after_initialize do
  next if Rails.env.test?

  missing = []

  unless ENV["LOCKBOX_MASTER_KEY"].present? || Rails.application.credentials.lockbox_master_key.present?
    missing << "LOCKBOX_MASTER_KEY"
  end

  %i[account_sid auth_token phone_number].each do |key|
    unless Rails.application.credentials.dig(:twilio, key).present?
      missing << "twilio.#{key}"
    end
  end

  %i[access_token location_id].each do |key|
    unless Rails.application.credentials.dig(:square, key).present?
      missing << "square.#{key}"
    end
  end

  if missing.any?
    Rails.logger.warn "[Schedulite] Missing credentials: #{missing.join(', ')}. Some features (SMS, gift cards) will be unavailable."
  end
end
