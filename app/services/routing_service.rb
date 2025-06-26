class RoutingService
  OSRM_URL = "https://router.project-osrm.org/route/v1/driving"

  def self.driving_time(from_lat:, from_lng:, to_lat:, to_lng:)
    return nil if [from_lat, from_lng, to_lat, to_lng].any?(&:blank?)

    uri = URI("#{OSRM_URL}/#{from_lng},#{from_lat};#{to_lng},#{to_lat}")
    uri.query = URI.encode_www_form(overview: "false")

    response = Net::HTTP.get_response(uri)
    return haversine_fallback(from_lat, from_lng, to_lat, to_lng) unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    return nil unless data["code"] == "Ok" && data["routes"]&.any?

    (data["routes"][0]["duration"] / 60.0).round
  rescue Net::ReadTimeout, Net::OpenTimeout, SocketError, JSON::ParserError => e
    Rails.logger.warn("OSRM routing failed, falling back to haversine: #{e.message}")
    haversine_fallback(from_lat, from_lng, to_lat, to_lng)
  end

  def self.haversine_fallback(lat1, lon1, lat2, lon2)
    r = 6371
    dlat = to_rad(lat2.to_f - lat1.to_f)
    dlon = to_rad(lon2.to_f - lon1.to_f)
    a = Math.sin(dlat / 2)**2 + Math.cos(to_rad(lat1.to_f)) * Math.cos(to_rad(lat2.to_f)) * Math.sin(dlon / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    distance_km = r * c
    (distance_km / 40.0 * 60).round
  end

  def self.to_rad(deg)
    deg * Math::PI / 180
  end

  private_class_method :haversine_fallback, :to_rad
end
