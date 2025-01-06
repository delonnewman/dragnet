module Dragnet
  class Geocoder
    def self.mock_location(location, latitude, longitude)
      @mocked_locations ||= {}
      @mocked_locations[location] = [latitude, longitude]
    end

    def self.mocked_locations
      @mocked_locations || EMPTY_HASH
    end
  end
end
