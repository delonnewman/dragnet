# frozen_string_literal: true

# Generate random surveys
#
# @see Survey
class Dragnet::SurveyGenerator < Dragnet::ActiveRecordGenerator
  DEFAULT_QUESTION_RANGE = (4..20)

  # @param [Hash] other_attributes Any valid Survey attribute (will override defaults)
  #
  # @return [Survey]
  def call(other_attributes = EMPTY_HASH)
    Survey.new(survey_attributes(other_attributes)) do |survey|
      num_questions(other_attributes).times do
        survey.questions << Question[question_attributes(survey, other_attributes)].generate
      end
    end
  end

  private

  # @param [Hash] others
  #
  # @return [Hash]
  def survey_attributes(others)
    attrs = attributes.merge(others).with_defaults!(default_attributes)
    attrs.delete(:questions) if attrs[:questions].is_a?(Hash) # remove question options/attributes
    attrs
  end

  def default_attributes
    {
      name:   Faker::Movie.title,
      author: User.generate,
      public: Faker::Boolean.boolean
    }
  end

  # @param [Hash] others
  #
  # @return [Hash]
  def question_attributes(survey, others)
    attributes
      .fetch(:questions, EMPTY_HASH)
      .merge(others.fetch(:questions, EMPTY_HASH))
      .with_defaults!(survey: survey)
      .except!(:count, :min, :max)
  end

  # @param [Hash] attributes
  #
  # @return [Integer]
  def num_questions(attributes)
    min, max, count = attributes.fetch(:questions, EMPTY_HASH).values_at(:min, :max, :count)
    return count if count

    nums = (min && max ? (min..max) : DEFAULT_QUESTION_RANGE).to_a
    raise "can't generate number from empty range" if nums.empty?

    nums.sample
  end
end
