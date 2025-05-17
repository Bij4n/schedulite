module API
  module V1
    class AppointmentsController < BaseController
      def index
        appointments = Appointment.today.chronological.includes(:patient, :provider)
        render json: {
          data: appointments.map { |a| serialize_appointment(a) }
        }
      end

      def create
        patient = find_or_create_patient
        appointment = Appointment.new(
          tenant: @api_key.tenant,
          patient: patient,
          provider_id: params.dig(:appointment, :provider_id),
          starts_at: params.dig(:appointment, :starts_at),
          external_id: params.dig(:appointment, :external_id),
          external_source: params.dig(:appointment, :external_source)
        )

        if appointment.save
          render json: { data: serialize_appointment(appointment) }, status: :created
        else
          render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        appointment = Appointment.find(params[:id])
        result = StatusChangeService.call(
          appointment: appointment,
          user: nil,
          new_status: params[:status],
          delay_minutes: params[:delay_minutes]&.to_i,
          note: params[:note]
        )

        if result.success?
          render json: { data: serialize_appointment(appointment.reload) }
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      private

      def find_or_create_patient
        appt_params = params[:appointment]
        phone = appt_params[:patient_phone]

        Patient.find_by(phone: phone, tenant: @api_key.tenant) ||
          Patient.create!(
            tenant: @api_key.tenant,
            first_name: appt_params[:patient_first_name],
            last_name: appt_params[:patient_last_name],
            phone: phone
          )
      end

      def serialize_appointment(appointment)
        {
          id: appointment.id,
          patient_name: appointment.patient.display_name,
          provider_name: appointment.provider.display_name,
          starts_at: appointment.starts_at.iso8601,
          status: appointment.status,
          delay_minutes: appointment.delay_minutes,
          signed_token: appointment.signed_token
        }
      end
    end
  end
end
