# frozen_string_literal: true

class Dragnet::QuestionTypesPresenter < Dragnet::View::Presenter
  presents as: :registrations

  def question_types_mapping
    types = registrations.pull(:name, :slug, :meta)

    types.reduce({}) do |qt, type|
      qt.merge!(type[:name] => type)
    end
  end
end
