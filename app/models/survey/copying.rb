# frozen_string_literal: true

class Survey::Copying < Dragnet::Advice
  advises Survey

  # @return [Survey, false]
  def copy!
    s     = copy
    saved = s.save!
    return s if saved

    false
  end

  # @return [Survey]
  def copy
    Survey.new(copy_data)
  end

  # @return [Hash]
  def copy_data
    survey.new_edit.survey_attributes.tap do |attrs|
      # TODO: remove all :id attributes
      attrs.delete(:id)
    end
  end
end