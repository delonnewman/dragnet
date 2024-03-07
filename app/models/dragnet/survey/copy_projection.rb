module Dragnet
  class Survey::CopyProjection
    def initialize(survey)
      @survey = survey
    end

    def project
      attribute_projection.to_h.tap do |attrs|
        attrs[:copy_of_id] = attrs.delete(:id)
        attrs.fetch(:questions_attributes, EMPTY_ARRAY).each do |q|
          q.delete(:id)
          q.fetch(:question_options_attributes, EMPTY_ARRAY).each do |opt|
            opt.delete(:id)
          end
        end
      end
    end
    alias to_h project

    def attribute_projection
      Survey::AttributeProjection.new(@survey.projection)
    end
  end
end
