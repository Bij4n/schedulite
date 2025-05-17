class WebhookDeliveryService
  def self.call(tenant:, event:, payload:)
    new(tenant: tenant, event: event, payload: payload).call
  end

  def initialize(tenant:, event:, payload:)
    @tenant = tenant
    @event = event
    @payload = payload
  end

  def call
    subscriptions.each { |sub| deliver(sub) }
  end

  private

  def subscriptions
    WebhookSubscription.where(tenant: @tenant).select { |s| s.matches_event?(@event) }
  end

  def deliver(subscription)
    body = { event: @event, payload: @payload, timestamp: Time.current.iso8601 }.to_json
    signature = subscription.compute_signature(body)

    uri = URI(subscription.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request["X-Webhook-Signature"] = signature
    request.body = body

    http.request(request)
  rescue StandardError => e
    Rails.logger.error("Webhook delivery failed for #{subscription.url}: #{e.message}")
  end
end
