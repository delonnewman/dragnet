# frozen_string_literal: true

module Dragnet
  # Cache answers in Replies to improve performance in the data grid
  class Reply::AnswersCache
    def initialize(reply)
      @reply = reply
    end

    def answers
      data!.map do |attributes|
        Answer.new(attributes)
      end
    end

    def data!
      raise 'No data in cache' unless data

      data
    end

    def data
      @reply.cached_answers_data
    end

    def set!
      @reply.cached_answers_data = pull_data
    end

    def pull_data
      @reply.answers.whole.pull(
        :id,
        :reply_id,
        :survey_id,
        :question_type_id,
        :question_id,
        :short_text_value,
        :long_text_value,
        :integer_value,
        :boolean_value,
        :float_value,
        :time_value,
        :date_value,
        :meta_data,
        :created_at,
        question_option: %i[id question_id text weight display_order]
      )
    end
  end
end
