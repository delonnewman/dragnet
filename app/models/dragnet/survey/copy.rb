module Dragnet
  module Survey::Copy
    def self.new(survey)
      Survey.new(data(survey))
    end

    def data(survey)
      attributes = Survey::AttributeProjection.new(survey.projection).to_h
      attributes.tap do |attrs|
        attrs[:copy_of_id] = attrs.delete(:id)
        attrs.fetch(:questions_attributes, EMPTY_ARRAY).each do |q|
          q.delete(:id)
          q.fetch(:question_options_attributes, EMPTY_ARRAY).each do |opt|
            opt.delete(:id)
          end
        end
      end
    end
  end
end
