module Dragnet
  class QuestionPresenter < View::Presenter
    presents Question, as: :question

    def field_name
      "filter_by[#{question.id}]"
    end
  end
end
