require 'geocoder'

module Dragnet
  module Ext
    class Address::DoBeforeSavingAnswer < Answer::DoBeforeSaving
      def address
        result = Geocoder.search(answer.short_text_value).first
        return unless result

        Rails.logger.info "Found geocoding result for #{answer.short_text_value.inspect}"
        Rails.logger.info "Storing #{result.latitude}, #{result.longitude}"

        Answer.transaction do
          latitude = answer.create_new_with!(float_value: result.latitude, short_text_value: 'latitude')
          longitude = answer.create_new_with!(float_value: result.longitude, short_text_value: 'longitude')

          answer.meta = {
            geodata: result,
            latitude_answer_id: latitude.id,
            longitude_answer_id: longitude.id,
            latitude: result.latitude,
            longitude: result.longitude,
          }
        end
      end
    end
  end
end
