# Project attributes suitable for ARs `accepts_nested_attributes_for` from
# edit survey data.
#
# @see SurveyEdit#survey_data
# @see Survey
# @see Question
# @see QuestionOption
class SurveyEdit::SurveyAttributeProjection < Dragnet::Advice
  advises SurveyEdit, as: :edit

  def attributes
    edit.survey_data.slice(:id, :name, :author_id, :description).tap do |attrs|
      attrs[:questions_attributes] = question_attributes
    end
  end

  # @param question [Question]
  def question_keys(question)
    %i[text display_order required question_type_id _destroy].tap do |keys|
      keys << :id unless question[:id].is_a?(Integer) && question[:id].negative?
    end
  end

  def question_data
    edit.survey_data[:questions] || EMPTY_ARRAY
  end

  def question_attributes
    question_data.map do |(_, q)|
      q.slice(*question_keys(q)).tap do |new|
        if q[:question_options].present?
          new[:question_options_attributes] = q[:question_options].map do |(_, opt)|
            opt.slice(*question_option_keys(opt))
          end
        end
      end
    end
  end

  def question_option_keys(option)
    %i[text weight _destroy].tap do |keys|
      keys << :id if option[:id].positive?
    end
  end
end
