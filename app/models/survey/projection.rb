# frozen_string_literal: true

# Survey projections that are used as the survey data in SurveyEdits
# and sent over the wire to the editor and submitter UI.
class Survey::Projection < Dragnet::Advice
  advises Survey

  def project
    data = survey_data

    data[:updated_at] = data[:updated_at]&.to_time

    questions = data[:questions].inject({}) do |qs, q|
      q[:question_options] = q[:question_options].inject({}) do |opts, opt|
        opts.merge!(opt[:id] => opt)
      end

      qs.merge!(q[:id] => q)
    end

    data.merge(questions: questions)
  end

  private

  def survey_data
    survey.pull(
      :id,
      :name,
      :description,
      :updated_at,
      :author_id,
      questions: [
        :id,
        :text,
        :display_order,
        :required,
        :settings,
        :question_type_id,
        {
          question_options: %i[id text weight],
          question_type:    %i[id slug name]
        }
      ]
    )
  end
end
