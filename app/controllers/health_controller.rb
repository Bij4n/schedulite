class HealthController < ActionController::API
  def show
    checks = {
      "database" => check_database,
      "redis" => check_redis,
      "twilio" => check_twilio
    }

    overall = checks.values.all? { |v| v == "ok" } ? "ok" : "degraded"
    status_code = checks["database"] == "ok" ? :ok : :service_unavailable

    render json: { status: overall, checks: checks }, status: status_code
  end

  private

  def check_database
    ActiveRecord::Base.connection.execute("SELECT 1")
    "ok"
  rescue => e
    "error: #{e.message}"
  end

  def check_redis
    redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
    redis.ping == "PONG" ? "ok" : "error: unexpected response"
  rescue => e
    "error: #{e.message}"
  end

  def check_twilio
    creds = Rails.application.credentials.dig(:twilio)
    if creds && creds[:account_sid].present? && creds[:auth_token].present?
      "ok"
    else
      "not_configured"
    end
  rescue => e
    "error: #{e.message}"
  end
end
