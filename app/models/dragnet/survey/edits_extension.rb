module Dragnet
  module Survey::EditsExtension
    def latest
      not_applied.order(created_at: :desc).first
    end
    
    def merge
      reduce(proxy_association.owner.projection) do |projection, edit| 
        edit.op.merge(edit, projection)
      end
    end

    def merged_attributes
      Survey::AttributeProjection.new(merge).to_h
    end

    def apply(timestamp = Time.zone.now)
      updates = merged_attributes
      updates[:questions_attributes].each { |q| q.delete(:id) if q[:id].to_i < 0 }

      # survey.edited.validate!(:application)
      Survey.transaction do
        proxy_association.owner.update!(updates)
        each { |edit| edit.apply!(timestamp) }
        Survey::EditingStatus.published!(proxy_association.owner)
      end
    end

    def new_question
      survey  = proxy_association.owner
      op      = SurveyEdit::Op.new_question
      details = {
        id:   op.temp_id(survey),
        text: op.new_text(survey),
        type: op.default_type,
      }
      create!(survey:, op:, details:)
    end

    def update_attributes(updates)
      survey = proxy_association.owner
      create!(survey:, op: SurveyEdit::Op.update, details: { updates: })
    end

    def update_question(question, updates)
      question_id = question.is_a?(Question) ? question.id : question
      survey      = proxy_association.owner
      create!(survey:, op: SurveyEdit::Op.update_question, details: { question_id:, updates: })
    end

    # TODO: when a survey has data it should retract the question
    def remove_question(question)
      question_id = question.is_a?(Question) ? question.id : question
      survey      = proxy_association.owner
      create!(survey:, op: SurveyEdit::Op.remove_question, details: { question_id: })
    end
  end
end
