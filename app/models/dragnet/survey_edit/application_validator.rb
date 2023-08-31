# frozen_string_literal: true

class Dragnet::SurveyEdit::ApplicationValidator < ActiveModel::Validator
  def validate(edit)
    unless edit.application.valid?(:application)
      edit.errors.merge!(edit.application.errors)
    end
  end
end
