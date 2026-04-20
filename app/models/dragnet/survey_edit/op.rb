module Dragnet
  # The survey edit operations that can be performed
  class SurveyEdit::Op < Enum
    member :Update do
      def merge(edit, projection)
        projection.merge(edit.details.fetch(:updates))
      end
    end

    member :NewQuestion, key: :new_question do
      def temp_id(survey)
        survey.meta[:new_question_id] ||= 0
        survey.meta[:new_question_id] -= 1
      end

      def new_text(survey)
        root  = 'New Question'
        count = survey.edited.questions.count { |q| q.text =~ /#{root}( \(\d\))?/ }
        if count < 1
          root
        else
          "#{root} (#{count})"
        end
      end

      def default_type = :text

      def merge(edit, projection)
        (id, text, type) = edit.details.values_at(:id, :text, :type)
        projection.merge(
          questions: projection[:questions].merge(
            id.to_s => {
              id: id.to_s,
              text:,
              type: type.to_sym,
              display_order: id,
            }
          )
        )
      end
    end

    member :UpdateQuestion, key: :update_question do
      def merge(edit, projection)
        question_id = edit.details.fetch(:question_id)
        updates = edit.details.fetch(:updates)
        projection.merge(
          questions: projection[:questions].merge(
            question_id =>
              projection[:questions].fetch(question_id).merge(updates)
          )
        )
      end
    end

    member :RemoveQuestion, key: :remove_question do
      def merge(edit, projection)
        question_id = edit.details.fetch(:question_id)
        return projection if question_id.to_i < 0
        projection.merge(
          questions: projection[:questions].merge(
            question_id => projection[:questions].fetch(question_id).merge(_destroy: true)
          )
        )
      end
    end
  end
end
