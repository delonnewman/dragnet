class SurveyDraft < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  def_delegators :draft, :valid?, :validate!, :errors

  def draft
    @draft ||= Survey.new(survey_data)
  end

  def published!(published_at = Time.now)
    self.published = true
    self.published_at = published_at
    self
  end

  def publish!(published_at = Time.now)
    SurveyDraft.transaction do
      survey.update(survey_attributes)
      published!(published_at).tap(&:save!)
    end
  end

  def survey_attributes
    survey_data.slice(:id, :name, :description).tap do |attrs|
      attrs[:questions_attributes] = survey_data[:questions].map do |(_, q)|
        q.slice(:text, :display_order, :required, :question_type_id).tap do |new|
          unless q[:question_options].blank?
            new[:question_options_attributes] = q[:question_options].map do |(_, opt)|
              new = opt.slice(:text, :weight)
              opt[:id].negative? ? new : new.merge!(id: opt[:id])
            end
          end

          new.merge!(id: q[:id]) if !q[:id].is_a?(Integer) || !q[:id].negative?
        end
      end
    end
  end
end
