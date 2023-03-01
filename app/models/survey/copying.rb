# frozen_string_literal: true

class Survey::Copying < Dragnet::Advice
  advises Survey

  def copy?
    survey.copy_of_id.present?
  end

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
