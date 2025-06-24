class GiftCardIssuanceService
  def self.call(appointment:)
    new(appointment: appointment).call
  end

  def initialize(appointment:)
    @appointment = appointment
  end

  def call
    return unless should_issue?
    return unless square_configured?

    response = client.create_gift_card(
      location_id: location_id,
      idempotency_key: "appointment_#{@appointment.id}"
    )

    gift_card_data = response.dig(:gift_card)
    return unless gift_card_data

    client.activate_gift_card(
      gift_card_id: gift_card_data[:id],
      location_id: location_id,
      amount_cents: settings.amount_cents,
      idempotency_key: "activate_appointment_#{@appointment.id}"
    )

    GiftCard.create!(
      appointment: @appointment,
      tenant: @appointment.tenant,
      amount_cents: settings.amount_cents,
      merchant_name: settings.merchant_name,
      merchant_url: settings.merchant_url,
      square_gan: gift_card_data[:gan],
      issued_at: Time.current
    )
  end

  private

  def should_issue?
    settings.present? &&
      @appointment.delay_minutes.to_i >= settings.delay_threshold_minutes &&
      @appointment.gift_cards.none?
  end

  def settings
    @settings ||= GiftCardSettings.find_by(tenant: @appointment.tenant)
  end

  def client
    @client ||= SquareClient.new(
      access_token: Rails.application.credentials.dig(:square, :access_token),
      environment: Rails.env.production? ? "production" : "sandbox"
    )
  end

  def square_configured?
    access_token = Rails.application.credentials.dig(:square, :access_token)
    unless access_token.present?
      Rails.logger.warn("Square not configured — skipping gift card issuance")
      return false
    end
    true
  end

  def location_id
    Rails.application.credentials.dig(:square, :location_id)
  end
end
