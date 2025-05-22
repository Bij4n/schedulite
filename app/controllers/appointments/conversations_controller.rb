module Appointments
  class ConversationsController < ApplicationController
    before_action :authenticate_user!

    def show
      @appointment = Appointment.includes(:patient, :provider).find(params[:appointment_id])
      @messages = @appointment.sms_messages.order(:created_at)
    end
  end
end
