Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    exceptions = %w[controller action format id]
    {
      params: event.payload[:params]
                    .except(*exceptions)
                    .reject { |k, _v| k.match?(/first_name|last_name|phone|date_of_birth|dob|diagnosis|reason|notes/i) }
    }
  end
end
