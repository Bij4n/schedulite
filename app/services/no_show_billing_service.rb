class NoShowBillingService
  def self.call(appointment:)
    new(appointment: appointment).call
  end

  def initialize(appointment:)
    @appointment = appointment
    @patient = appointment.patient
    @tenant = appointment.tenant
  end

  def call
    return unless should_charge?

    charge = create_charge_record

    begin
      payment_intent = Stripe::PaymentIntent.create(
        amount: fee_cents,
        currency: "usd",
        customer: @patient.stripe_customer_id,
        payment_method: @patient.stripe_payment_method_id,
        off_session: true,
        confirm: true,
        description: "No-show fee for appointment on #{@appointment.starts_at.strftime('%B %-d, %Y')}",
        metadata: {
          appointment_id: @appointment.id,
          tenant_id: @tenant.id
        }
      )

      charge.update!(status: "charged", stripe_charge_id: payment_intent.id)
      send_charge_notification(charge)
      charge
    rescue Stripe::CardError, Stripe::InvalidRequestError => e
      charge.update!(status: "failed", stripe_charge_id: e.message)
      Rails.logger.error("No-show charge failed for appointment #{@appointment.id}: #{e.message}")
      charge
    end
  end

  private

  def should_charge?
    fee_cents.to_i > 0 && @patient.card_on_file?
  end

  def fee_cents
    @tenant.no_show_fee_cents
  end

  def create_charge_record
    NoShowCharge.create!(
      appointment: @appointment,
      patient: @patient,
      tenant: @tenant,
      amount_cents: fee_cents,
      status: "pending"
    )
  end

  def send_charge_notification(charge)
    return unless @patient.sms_consent? && @patient.phone.present?

    SmsService.call(
      patient: @patient,
      appointment: @appointment,
      template: :no_show_fee,
      fee_amount: "$#{'%.2f' % charge.amount_dollars}"
    )
  rescue => e
    Rails.logger.error("No-show SMS failed: #{e.message}")
  end
end
