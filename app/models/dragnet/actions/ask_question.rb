module Dragnet
  module Actions
    class AskQuestion < Action
      attr_reader :question

      def initialize(**attributes)
        super

        @question = attributes.fetch(:question) do
          raise "a question is required"
        end
      end

      def call
        { question.id => answers }
      end

      def partial?
        params.empty? || unanswered?
      end

      def unanswered?
        return answers.nil? unless question.required?

        answers.nil? || answers.empty?
      end

      def answers
        params.dig(:reply, :answers, question.id)
      end
    end
  end
end
