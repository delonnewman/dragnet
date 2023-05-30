# frozen_string_literal: true

class Answer::Evaluation < Dragnet::Advice
  advises Answer

  delegate :question_type, :question, :question_option, to: :advised_object
  delegate :float_value, :integer_value, :short_text_value, :long_text_value, to: :advised_object
  delegate :to_s, :blank?, to: :value
  delegate :to_i, :to_f, to: :number_value

  class Error < StandardError; end

  def assign_value!(value)
    case question_type.ident
    when :text
      if question.long_answer?
        answer.long_text_value = value
      else
        answer.short_text_value = value
      end
    when :choice
      answer.question_option = value
    when :number
      answer.float_value = value
    when :time
      if value.respond_to?(:to_time)
        answer.integer_value = value.to_time.to_i
      else
        answer.integer_value = value
      end
    else
      raise Error, "can't evaluate #{value.inspect}:#{value.class}"
    end
  end
  alias value= assign_value!

  def value
    case question_type.ident
    when :text
      return long_text_value if question.long_answer?

      short_text_value
    when :choice
      question_option&.text
    when :time
      t = Time.at(integer_value)
      return t if question.include_time?

      t.to_date
    when :number
      float_value
    else
      raise Error, "can't convert #{question_type} to text"
    end
  end

  def text_value
    value.to_s
  end

  def number_value
    case question_type.ident
    when :choice
      question_option&.weight
    when :number
      float_value
    when :time
      integer_value
    else
      raise Error, "can't convert #{question_type} to number"
    end
  end

  def assign_sort_value!
    answer.sort_value = sort_value
  end

  # TODO: need to figure out how to generate a value that will sort number correctly, also should be extensible
  def sort_value
    number_value
  rescue Error
    text_value
  end
end
