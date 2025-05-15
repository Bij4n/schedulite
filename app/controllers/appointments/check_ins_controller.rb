module Appointments
  class CheckInsController < ApplicationController
    before_action :authenticate_user!

    def update
      @appointment = Appointment.find(params[:id])
      result = StatusChangeService.call(
        appointment: @appointment,
        user: current_user,
        new_status: "checked_in"
      )

      if result.success?
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to root_path, notice: "Patient checked in" }
        end
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              ActionView::RecordIdentifier.dom_id(@appointment),
              AppointmentRowComponent.new(appointment: @appointment).render_in(view_context)
            ), status: :unprocessable_entity
          end
          format.html { redirect_to root_path, alert: result.error }
        end
      end
    end
  end
end
