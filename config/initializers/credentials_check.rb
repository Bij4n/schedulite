Rails.application.config.after_initialize do
  next if Rails.env.test?

  # Boot-time DB sanity check — surfaces "users table doesn't exist" or any
  # other DB connection issue with a recognizable tag in the deploy logs.
  if Rails.env.production?
    begin
      ActiveRecord::Base.connection.execute("SELECT 1 FROM users LIMIT 0")
      Rails.logger.info("[BOOT-CHECK] users table OK")
    rescue => e
      Rails.logger.error("[BOOT-CHECK] users table check FAILED: #{e.class} #{e.message}")
    end
  end

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
