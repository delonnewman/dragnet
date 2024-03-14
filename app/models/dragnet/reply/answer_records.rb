# frozen_string_literal: true

module Dragnet
  class Reply::AnswerRecords
    QUESTION_ATTRIBUTES = {
      :question_type     => :question_type_attributes,
      'question_type'    => :question_type_attributes,
      :question_options  => :question_options_attributes,
      'question_options' => :question_options_attributes,
    }.freeze

    def self.build(answer_data)
      attributes(answer_data).map do |attributes|
        Answer.new(attributes)
      end
    end

    def self.attributes(answer_data)
      answer_data.map do |answer|
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

    attr_reader :data

    def initialize(reply)
      @data = pull_data(reply.answers.whole).freeze
    end

    def attributes
      self.class.attributes(@data)
    end

    def build
      self.class.build(@data)
    end

    private

    def pull_data(answers)
      answers.pull(
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
        question: %i[id text hash_code display_order required survey_id retracted retracted_at meta_data question_type question_options]
      )
    end
  end
end
