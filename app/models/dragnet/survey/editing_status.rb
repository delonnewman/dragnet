module Dragnet
  class Survey::EditingStatus < Enum
    member :Published, value: 0 do
      def color_class = 'bg-green'
    end

    member :Unpublished, value: 1 do
      def color_class = 'bg-warning'
    end

    member :CannotPublish, value: -1 do
      def color_class = 'bg-danger'
    end

    def self.assign_default!(survey)
      saved!(survey) unless survey.edits_status?
    end

    def self.saved!(survey)
      survey.edits_status = :saved
    end

    def self.update!(edit)
      return if edit.applied?

      if edit.edited_survey.valid?
        edit.survey.update(edits_status: :unsaved)
      else
        edit.survey.update(edits_status: :cannot_save)
      end
    end
  end
end
