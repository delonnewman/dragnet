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
        question = Question.new(survey_id: edit.survey_id).tap(&:validate!)
        id = edit.details.fetch(:id).to_s
        projection.merge(
          questions: projection[:questions].merge(
            id => {
              id:,
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
            question_id =>
              projection[:questions].fetch(question_id).merge(updates).merge(_update: true)
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
