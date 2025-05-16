module Integrations
  class SyncJob < ApplicationJob
    queue_as :default

    def perform(integration_id)
      integration = Integration.find(integration_id)
      adapter = AdapterFactory.build(integration)
      dtos = adapter.fetch_appointments(date_range: Date.current..Date.current)

      ActsAsTenant.with_tenant(integration.tenant) do
        dtos.each { |dto| upsert_appointment(integration.tenant, dto) }
      end

      integration.update!(last_synced_at: Time.current)
    end

    private

    def upsert_appointment(tenant, dto)
      patient = find_or_create_patient(tenant, dto)
      provider = find_or_create_provider(tenant, dto)

      appointment = Appointment.find_or_initialize_by(
        external_id: dto.external_id,
        external_source: dto.external_source,
        tenant: tenant
      )

      appointment.assign_attributes(
        patient: patient,
        provider: provider,
        starts_at: dto.starts_at,
        ends_at: dto.ends_at,
        notes: dto.notes
      )

      appointment.save!
    end

    def find_or_create_patient(tenant, dto)
      Patient.find_by(phone: dto.patient_phone, tenant: tenant) ||
        Patient.create!(
          tenant: tenant,
          first_name: dto.patient_first_name,
          last_name: dto.patient_last_name,
          phone: dto.patient_phone,
          date_of_birth: dto.patient_dob
        )
    end

    def find_or_create_provider(tenant, dto)
      return Provider.first if dto.provider_last_name.blank?

      Provider.find_by(first_name: dto.provider_first_name, last_name: dto.provider_last_name, tenant: tenant) ||
        Provider.create!(
          tenant: tenant,
          first_name: dto.provider_first_name,
          last_name: dto.provider_last_name,
          title: dto.provider_title
        )
    end
  end
end
