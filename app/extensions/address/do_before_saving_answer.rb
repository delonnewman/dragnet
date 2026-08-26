module Dragnet
  module Ext
    class Address::DoBeforeSavingAnswer < Answer::DoBeforeSaving
      def address
        # geo code address and stash lat and long in two float values
        text = answer.text_value
        if (result = ::Geocoder.search(text).first)
          Rails.logger.info "Geocoding #{text} to #{result}"

          answer.float_value = result.latitude
          answer.reply.answers.create!(
            question_id: answer.question_id,
            survey_id: answer.survey_id,
            float_value: result.longitude
          )
        else
          Rails.logger.info "No geocoding found for #{text}"
        end
      end
    end
  end
end
