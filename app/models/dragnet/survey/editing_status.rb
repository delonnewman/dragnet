module Dragnet
  class Survey::EditingStatus
    def self.default!(survey)
      saved!(survey) unless survey.edits_status?
    end

    def self.saved!(survey)
      survey.edits_status = :saved
    end

    def self.update!(edit)
      return if edit.applied?

      if edit.validating_survey.valid?
        edit.survey.update(edits_status: :unsaved)
      else
        edit.survey.update(edits_status: :cannot_save)
      end
    end
  end
end
