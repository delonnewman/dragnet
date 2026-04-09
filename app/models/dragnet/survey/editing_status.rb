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
      saved!(survey) unless survey.editing_status?
    end

    def self.saved!(survey)
      survey.editing_status = published
    end

    def self.update!(edit)
      return if edit.applied?
      return edit.survey.update(editing_status: unpublished) if edit.edited_survey.valid?

      edit.survey.update(editing_status: cannot_publish)
    end
  end
end
