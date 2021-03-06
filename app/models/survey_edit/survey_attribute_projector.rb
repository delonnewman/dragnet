# Project attributes suitable for ARs `accepts_nested_attributes_for` from
# edit survey data.
#
# @see SurveyEdit#survey_data
# @see Survey
# @see Question
# @see QuestionOption
class SurveyEdit::SurveyAttributeProjector
  def initialize(edit)
    @edit = edit
  end

  private

  attr_reader :edit

  def question_keys(question)
    %i[text display_order required question_type_id _destroy].tap do |keys|
      keys << :id unless question[:id].is_a?(Integer) && question[:id].negative?
    end
  end

  def add_question_attributes!(attrs)
    attrs[:questions_attributes] = edit.survey_data[:questions].map do |(_, q)|
      q.slice(*question_keys(q)).tap do |new|
        add_question_options_attributes!(new, q)
      end
    end
  end

  def question_option_keys(option)
    %i[text weight _destroy].tap do |keys|
      keys << :id if option[:id].positive?
    end
  end

  def add_question_options_attributes!(new, old)
    return if old[:question_options].blank?

    new[:question_options_attributes] = old[:question_options].map do |(_, opt)|
      opt.slice(*question_option_keys(opt))
    end
  end

  public

  def call
    edit.survey_data.slice(:id, :name, :description).tap do |attrs|
      add_question_attributes!(attrs)
    end
  end
end