# frozen_string_literal: true

class Dragnet::QuestionTypesPresenter < Dragnet::View::Presenter
  presents as: :registrations

  def question_types_mapping
    data = registrations.pull(:name, :type_class_name, :slug, :meta_data).map do |reg|
      reg.transform do |key, value|
        if key == :meta_data
          value.deep_symbolize_keys
        else
          value
        end
      end
    end

    data.index_by { |d| d[:type_class_name] }
  end
end
