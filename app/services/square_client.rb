class SquareClient
  BASE_URL = "https://connect.squareupsandbox.com/v2".freeze
  PRODUCTION_URL = "https://connect.squareup.com/v2".freeze

  def initialize(access_token:, environment: "sandbox")
    @access_token = access_token
    @base_url = environment == "production" ? PRODUCTION_URL : BASE_URL
  end

  def create_gift_card(location_id:, idempotency_key:)
    post("/gift-cards", {
      idempotency_key: idempotency_key,
      location_id: location_id,
      gift_card: { type: "DIGITAL" }
    })
  end

  def activate_gift_card(gift_card_id:, location_id:, amount_cents:, idempotency_key:)
    post("/gift-cards/activities", {
      idempotency_key: idempotency_key,
      gift_card_activity: {
        gift_card_id: gift_card_id,
        type: "ACTIVATE",
        location_id: location_id,
        activate_activity_details: {
          amount_money: { amount: amount_cents, currency: "USD" }
        }
      }
    })
  end

  private

  def post(path, body)
    uri = URI("#{@base_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["Authorization"] = "Bearer #{@access_token}"
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request.body = body.to_json

    response = http.request(request)
    JSON.parse(response.body, symbolize_names: true)
  end
end
