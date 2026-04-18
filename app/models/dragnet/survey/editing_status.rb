module Dragnet
  class Survey::EditingStatus < Enum
    member :Published, value: 0 do
      def bg_color_class = 'bg-success'
      def description = 'All changes published'
    end

    member :Unpublished, value: 1 do
      def bg_color_class = 'bg-warning'
      def description = 'Unpublished changes'
    end

    member :CannotPublish, value: -1, key: :cannot_publish do
      def bg_color_class = 'bg-danger'
      def description = 'Cannot publish changes'
    end

    def self.assign_default!(survey)
      saved!(survey) unless survey.editing_status?
    end

    def self.published!(survey)
      survey.update(editing_status: :published)
    end

    def self.update!(edit)
      return if edit.applied?
      return edit.survey.update(editing_status: :unpublished) if edit.survey.edited.valid?(:application)

      edit.survey.update(editing_status: :cannot_publish)
    end
  end
end
