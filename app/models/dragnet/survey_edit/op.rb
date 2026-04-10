module Dragnet
  # The survey edit operations that can be performed
  class SurveyEdit::Op < Enum
    member :Update do
      def merge(edit, projection)
        projection.merge(edit.details.fetch(:updates))
      end
    end

    member :NewQuestion, key: :new_question do
      def merge(edit, projection)
        question = Question.find_or_create_by!(survey_id: edit.survey_id)
        projection.merge(
          questions: projection[:questions].merge(
            question.id => {
              id: question.id,
              text: question.text,
              type: question.type.symbol,
              display_order: question.display_order,
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
            question_id => projection[:questions].fetch(question_id).merge(updates)
          )
        )
      end
    end

    member :RemoveQuestion, key: :remove_question do
      def merge(edit, projection)
        question_id = edit.details.fetch(:question_id)
        projection.merge(
          questions: projection[:questions].except(question_id)
        )
      end
    end
  end
end
