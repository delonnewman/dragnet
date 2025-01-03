module Dragnet
  module Types
    class Text < Basic
      perform :do_before_saving_answer, class_name: 'Dragnet::Action::DoBeforeSavingAnswer'

      def calculate_sentiment?(question)
        question.settings.long_answer? && question.settings.countable?
      end
    end
  end
end
