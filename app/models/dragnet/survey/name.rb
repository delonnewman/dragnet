module Dragnet
  module Survey::Name
    def self.assign!(survey)
      name = unique_name(survey)
      survey.name = name.as_name if name.generate?
      survey.slug = name.as_slug if name.generate? || assign_slug?(survey)
    end

    def self.unique_name(survey)
      UniqueName.new(survey, scope: :author_id)
    end

    def self.assign_slug?(survey)
      survey.name.present? && survey.slug.blank?
    end
  end
end
