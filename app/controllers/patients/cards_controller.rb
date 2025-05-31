module Patients
  class CardsController < ApplicationController
    before_action :authenticate_user!

    def new
      @patient = Patient.find(params[:patient_id])
      @stripe_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key) || ENV["STRIPE_PUBLISHABLE_KEY"] || ""
    end

    def create
      @patient = Patient.find(params[:patient_id])
      payment_method_id = params[:payment_method_id]

      if payment_method_id.blank?
        redirect_to new_patient_card_path(@patient), alert: "Card information is required"
        return
      end

      begin
        StripeCardService.save_card(patient: @patient, payment_method_id: payment_method_id)
        redirect_to patient_path(@patient), notice: "Card saved successfully"
      rescue Stripe::StripeError => e
        redirect_to new_patient_card_path(@patient), alert: "Card error: #{e.message}"
      end
    end

    def destroy
      @patient = Patient.find(params[:patient_id])
      @patient.update!(
        stripe_payment_method_id: nil,
        card_last4: nil,
        card_brand: nil
      )
      redirect_to patient_path(@patient), notice: "Card removed"
    end
  end
end
