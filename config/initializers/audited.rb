Audited.config do |config|
  config.max_audits = nil
end

# Allow audited to serialize Date and Time objects in YAML audit records
# Required for Lockbox virtual attributes that return Date types
Rails.application.config.active_record.yaml_column_permitted_classes = [Date, Time, DateTime, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]
