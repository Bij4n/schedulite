class GeocodingService
  NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"

  def self.geocode(address)
    return nil if address.blank?

    uri = URI(NOMINATIM_URL)
    uri.query = URI.encode_www_form(
      q: address,
      format: "json",
      limit: 1
    )

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    results = JSON.parse(response.body)
    return nil if results.empty?

    {
      latitude: results[0]["lat"].to_f,
      longitude: results[0]["lon"].to_f
    }
  rescue Net::ReadTimeout, Net::OpenTimeout, SocketError, JSON::ParserError => e
    Rails.logger.warn("Geocoding failed for address: #{e.message}")
    nil
  end
end
