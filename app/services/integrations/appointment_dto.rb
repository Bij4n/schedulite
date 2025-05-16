module Integrations
  class AppointmentDTO
    attr_reader :external_id, :external_source,
                :patient_first_name, :patient_last_name, :patient_phone, :patient_dob,
                :provider_first_name, :provider_last_name, :provider_title,
                :starts_at, :ends_at, :status, :notes

    def initialize(external_id:, external_source:, patient_first_name:, patient_last_name:, patient_phone:,
                   starts_at:, patient_dob: nil, provider_first_name: nil, provider_last_name: nil,
                   provider_title: nil, ends_at: nil, status: "scheduled", notes: nil)
      @external_id = external_id
      @external_source = external_source
      @patient_first_name = patient_first_name
      @patient_last_name = patient_last_name
      @patient_phone = patient_phone
      @patient_dob = patient_dob
      @provider_first_name = provider_first_name
      @provider_last_name = provider_last_name
      @provider_title = provider_title
      @starts_at = starts_at
      @ends_at = ends_at
      @status = status
      @notes = notes
    end
  end
end
