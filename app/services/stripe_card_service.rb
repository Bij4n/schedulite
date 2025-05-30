class StripeCardService
  def self.save_card(patient:, payment_method_id:)
    new(patient: patient, payment_method_id: payment_method_id).call
  end

  def initialize(patient:, payment_method_id:)
    @patient = patient
    @payment_method_id = payment_method_id
  end

  def call
    customer = find_or_create_customer
    attach_payment_method(customer.id)
    update_patient(customer.id)
  end

  private

  def find_or_create_customer
    if @patient.stripe_customer_id.present?
      Stripe::Customer.retrieve(@patient.stripe_customer_id)
    else
      Stripe::Customer.create(
        metadata: { patient_id: @patient.id, tenant_id: @patient.tenant_id }
      )
    end
  end

  def attach_payment_method(customer_id)
    Stripe::PaymentMethod.attach(@payment_method_id, customer: customer_id)
    Stripe::Customer.update(customer_id, invoice_settings: { default_payment_method: @payment_method_id })
  end

  def update_patient(customer_id)
    pm = Stripe::PaymentMethod.retrieve(@payment_method_id)
    card = pm.card

    @patient.update!(
      stripe_customer_id: customer_id,
      stripe_payment_method_id: @payment_method_id,
      card_last4: card.last4,
      card_brand: card.brand
    )
  end
end
