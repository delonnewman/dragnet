# frozen_string_literal: true

# Logic for survey edits
class Survey::Editing
  attr_reader :survey

  def initialize(survey)
    @survey = survey
  end

  def latest_edit
    survey.edits.where(applied: false).order(created_at: :desc).first
  end

  def edited?
    latest_edit.present?
  end

  def current_edit
    latest_edit || new_edit
  end

  def new_edit
    SurveyEdit.new(survey: survey, survey_data: projection)
  end

  def projection
    data = survey.pull(
      :id,
      :name,
      :description,
      :updated_at,
      questions: [
        :id,
        :text,
        :display_order,
        :required,
        :question_type_id,
        {
          question_options: %i[id text weight]
        }
      ]
    )

    data[:updated_at] = data[:updated_at].to_time

    questions = data[:questions].inject({}) do |qs, q|
      q[:question_options] = q[:question_options].inject({}) do |opts, opt|
        opts.merge!(opt[:id] => opt)
      end

      qs.merge!(q[:id] => q)
    end

    data.merge(questions: questions)
  end
end
