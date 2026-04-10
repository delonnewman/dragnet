module Dragnet
  # The survey edit operations that can be performed
  class SurveyEdit::Op < Enum
    member :Update, value: 0 do
      def merge(edit, projection)
        projection.merge(edit.details.fetch(:updates))
      end
    end

    member :NewQuestion, value: 1, key: :new_question do
      def merge(edit, projection)
        question = Question.new(id: Utils.uuid, survey_id: edit.survey_id).tap(&:validate!)
        projection.merge(
          questions: projection[:questions].merge(
            question.id => {
              id: question.id,
              text: question.text,
              type_class_name: question.type_class_name,
              display_order: question.display_order,
            }
          )
        )
      end
    end

    member :UpdateQuestion, value: 2, key: :update_question do
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

    member :RemoveQuestion, value: 3, key: :remove_question do
      def merge(edit, projection)
        question_id = edit.details.fetch(:question_id)
        projection.merge(
          questions: projection[:questions].slice(question_id)
        )
      end
    end
  end
end
