# frozen_string_literal: true

class Dragnet::QuestionTypesPresenter < Dragnet::View::Presenter
  presents as: :registrations

  def question_types_mapping
    data = registrations.map do |reg|
      {
        name: reg.name,
        slug: reg.slug,
        key: reg.type_class.symbol,
        meta: reg.meta.to_h,
      }
    end

    data.index_by { |d| d[:symbol] }
  end
end
