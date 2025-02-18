# frozen_string_literal: true

module Dragnet
  # Cache answers in Replies to improve performance in the data grid
  class Reply::AnswersCache
    def initialize(reply)
      @reply = reply
      @setting = false
    end

    def answers
      data.map do |attributes|
        Answer.new(attributes)
      end
    end

    def data
      @reply.cached_answers_data
    end

    def set!
      @setting = true
      @reply.update_attribute(:cached_answers_data, pull_data)
      @setting = false
    end

    def should_set?
      @reply.submitted? && !set? && !@setting
    end

    def set?
      @reply.cached_answers_data.present?
    end

    private

    def pull_data
      @reply.answers.whole.pull(
        :id,
        :reply_id,
        :survey_id,
        :type_class_name,
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
