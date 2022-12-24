# frozen_string_literal: true

class QuestionTypesPresenter < Dragnet::View::Presenter
  presents as: :question_types

  def question_types_mapping
    types = question_types.pull(:id, :name, :slug, :icon, settings: [:*])

    types.reduce({}) do |qt, type|
      qt.merge!(type[:id] => type)
    end
  end
end
