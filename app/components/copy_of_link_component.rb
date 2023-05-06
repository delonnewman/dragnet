# frozen_string_literal: true

class CopyOfLinkComponent < ApplicationComponent
  attribute :survey, required: true
  attribute :user, required: true

  template do
    tag.small(class: 'text-muted fw-normal') do
      tag.text('Copy of') + tag.nbsp + label
    end
  end

  def label
    return survey.copy_of.name unless survey.copy_of.author_id == user.id

    tag.a(href: survey_path(survey.copy_of), class: 'text-muted') do
      survey.copy_of.name
    end
  end
end
