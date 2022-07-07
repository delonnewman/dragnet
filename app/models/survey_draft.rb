class SurveyDraft < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  def_delegators :draft, :valid?, :validate!, :errors

  def draft
    @draft ||= Survey.new(survey_data)
  end

  def applied!(timestamp = Time.now)
    self.applied = true
    self.applied_at = timestamp
    self
  end

  def apply!(timestamp = Time.now)
    SurveyDraft.transaction do
      # Commit changes to survey
      survey_attributes.tap do |attrs|
        logger.info "Applying attrs: #{attrs.pretty_inspect}"
        survey.update(attrs)
      end

      # Mark this draft as published
      applied!(timestamp).save!

      # Clean up old drafts
      survey
        .drafts
        .where.not(id: id)
        .delete_all

      self
    end
  end

  def survey_attributes
    survey_data.slice(:id, :name, :description).tap do |attrs|
      attrs[:questions_attributes] = survey_data[:questions].map do |(_, q)|
        keys = %i[text display_order required question_type_id _destroy]
        keys << :id unless q[:id].is_a?(Integer) && q[:id].negative?
        q.slice(*keys).tap do |new|
          unless q[:question_options].blank?
            new[:question_options_attributes] = q[:question_options].map do |(_, opt)|
              keys = %i[text weight _destroy]
              keys << :id if opt[:id].positive?
              opt.slice(*keys)
            end
          end
        end
      end
    end
  end
end
