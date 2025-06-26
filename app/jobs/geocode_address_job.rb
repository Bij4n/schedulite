class GeocodeAddressJob < ApplicationJob
  queue_as :low

  def perform(record_type, record_id)
    record = record_type.constantize.find_by(id: record_id)
    return unless record

    address = record.respond_to?(:full_address) ? record.full_address : record.address
    return if address.blank?

    coords = GeocodingService.geocode(address)
    return unless coords

    record.update_columns(
      latitude: coords[:latitude],
      longitude: coords[:longitude]
    )
  end
end
