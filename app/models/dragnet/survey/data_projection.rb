# frozen_string_literal: true

module Dragnet
  # Survey projections that are used as the survey data in SurveyEdits
  # and sent over the wire to the editor and submitter UI.
  #
  # @see SurveyEdit#survey_data
  # @see Survey::AttributeProjection
  class Survey::DataProjection
    def initialize(survey)
      @survey = survey
    end

    def project
      data = survey_data
      data[:updated_at] = data[:updated_at]&.to_time

      questions = data[:questions].inject({}) do |qs, q|
        q[:question_options] = q[:question_options].inject({}) do |opts, opt|
          opts.merge!(opt[:id] => opt)
        end

        qs.merge!(q[:id] => q)
      end

      data.merge(questions:)
    end
    alias to_h project

    private

    def survey_data
      @survey.pull(
        :id,
        :name,
        :description,
        :updated_at,
        :author_id,
        :edits_status,
        author: %i[id name nickname],
        questions: [
          :id,
          :text,
          :display_order,
          :required,
          :config,
          :question_type_id,
          {
            question_options: %i[id text weight],
            question_type: %i[id slug name],
          },
        ]
      )
    end
  end
end
