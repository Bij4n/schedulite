class Rack::Attack
  # Use a dedicated in-memory store rather than Rails.cache. If Rails.cache
  # is backed by Redis and Redis goes down, every request that hits a throttle
  # or blocklist would otherwise raise Redis::CannotConnectError and 500.
  # In-memory is also the right choice for single-instance free-tier deploys.
  # In tests, fall back to the null cache so counters don't bleed across examples.
  Rack::Attack.cache.store = if Rails.env.test?
    ActiveSupport::Cache::NullStore.new
  else
    ActiveSupport::Cache::MemoryStore.new
  end

  # Throttle sign-in attempts by IP
  throttle("logins/ip", limit: 10, period: 60.seconds) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Throttle sign-in attempts by email
  throttle("logins/email", limit: 5, period: 60.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Throttle API requests by API key
  throttle("api/key", limit: 100, period: 60.seconds) do |req|
    req.env["HTTP_X_API_KEY"] if req.path.start_with?("/api/")
  end

  # Throttle registration attempts
  throttle("registrations/ip", limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == "/register" && req.post?
  end

  # Throttle webhook endpoints
  throttle("webhooks/ip", limit: 60, period: 60.seconds) do |req|
    req.ip if req.path.start_with?("/webhooks/")
  end

  # Block suspicious IPs (customize in production)
  blocklist("block bad IPs") do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 20, findtime: 5.minutes, bantime: 1.hour) do
      req.path == "/users/sign_in" && req.post?
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |req|
    [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded. Try again later." }.to_json]]
  end
end
