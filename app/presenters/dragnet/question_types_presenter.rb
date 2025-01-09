# frozen_string_literal: true

class Dragnet::QuestionTypesPresenter < Dragnet::View::Presenter
  presents as: :registrations

  def question_types_mapping
    data = registrations.map do |reg|
      {
        name: reg.name,
        slug: reg.slug,
        symbol: reg.type_class.symbol,
        tags: reg.type_class.tags,
        meta: reg.meta.to_h,
      }
    end

    data.index_by { |d| d[:symbol] }
  end
end
