Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params]
    return {} unless params.is_a?(Hash)

    exceptions = %w[controller action format id]
    {
      params: params
                .except(*exceptions)
                .reject { |k, _v| k.match?(/first_name|last_name|phone|date_of_birth|dob|diagnosis|reason|notes/i) }
    }
  end
end
