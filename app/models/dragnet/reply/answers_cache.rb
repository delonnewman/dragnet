# frozen_string_literal: true

module Dragnet
  class Reply::AnswersCache
    include Memoizable

    def initialize(reply)
      @reply = reply
    end

    def answers
      attributes.map do |attributes|
        Answer.new(attributes)
      end
    end
    memoize :answers

    QUESTION_ATTRIBUTES = {
      :question_type     => :question_type_attributes,
      'question_type'    => :question_type_attributes,
      :question_options  => :question_options_attributes,
      'question_options' => :question_options_attributes,
    }.freeze
    private_constant :QUESTION_ATTRIBUTES

    def attributes
      data!.map do |answer|
        answer.transform do |key, value|
          case key
          when :question, 'question'
            Question.new(value.transform_keys(QUESTION_ATTRIBUTES))
          when :question_type, 'question_type'
            QuestionType.new(value)
          when :question_option, 'question_option'
            QuestionOption.new(value)
          else
            value
          end
        end
      end
    end

    def data!
      raise 'No data in cache' unless data

      data
    end

    def data
      @reply.cached_answers_data
    end

    def reset!
      @reply.cached_answers_data = pull_data
    end

    def pull_data
      @reply.answers.whole.pull(
        :id,
        :reply_id,
        :survey_id,
        :short_text_value,
        :long_text_value,
        :integer_value,
        :boolean_value,
        :float_value,
        :time_value,
        :date_value,
        :retracted,
        :retracted_at,
        :meta_data,
        :created_at,
        :updated_at,
        :question_option,
        :question_type,
        question: [
          :id,
          :text,
          :hash_code,
          :display_order,
          :required,
          :survey_id,
          :retracted,
          :retracted_at,
          :meta_data,
          {
            question_type: %i[id name slug type_class_name parent_type_id meta_data],
            question_options: %i[id text weight display_order],
          },
        ]
      )
    end
  end
end
