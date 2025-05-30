class SmsConsentService
  def self.request_consent(patient:, appointment:)
    return if patient.sms_consent?
    return if patient.phone.blank?

    body = SmsTemplate.render(:consent_request, {
      practice_name: patient.tenant.name
    })

    SmsService.call(
      patient: patient,
      appointment: appointment,
      template: :consent_request,
      practice_name: patient.tenant.name
    )
  rescue => e
    Rails.logger.error("SMS consent request failed for patient #{patient.id}: #{e.message}")
  end
end
