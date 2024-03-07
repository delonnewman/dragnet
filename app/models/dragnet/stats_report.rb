# frozen_string_literal: true

module Dragnet
  # Report stats for a reportable object
  class StatsReport
    include Constants

    attr_reader :reportable

    delegate :questions, :name, to: :reportable

    # @param reportable [#records, #answers, #events]
    def initialize(reportable)
      @reportable = reportable
    end

    # @return [ActiveRecord::Relation<Question>]
    def countable_questions
      questions.select { _1.settings.countable? }
    end

    # @return [Integer]
    def reply_count
      reportable.records.count
    end

    # @return [ActiveRecord::Relation<Ahoy::View>]
    def views
      reportable.events.where(name: ReplyTracker::EVENT_TAGS[:view])
    end

    # @return [Integer]
    def view_count
      views.count
    end

    # TODO: Add average time to complete
    # @return [Float, nil]
    def completion_rate
      return if view_count.zero?

      (reply_count.to_f / view_count) * 100
    end

    # @return [Hash{Date, Integer}]
    def replies_by_date
      reportable
        .records
        .group('replies.created_at::date')
        .count
    end

    # @return [Hash{String, Integer}]
    def replies_by_month
      data = reportable.records.group('extract(month from replies.created_at)').count

      MONTH_DEFAULT.merge(data).transform_keys do |key|
        Date::MONTHNAMES[key.to_i]
      end
    end

    # @return [Hash{String, Integer}]
    def replies_by_time_of_day
      data = reportable.records.group('extract(hour from replies.created_at)').count

      TIME_OF_DAY_DEFAULT.merge(data).transform_keys do |key|
        TimeUtils.fmt_hour(key.to_i)
      end
    end

    # @return [Hash{String, Integer}]
    def replies_by_weekday
      data = reportable.records.group('extract(dow from replies.created_at)').count

      WEEKDAY_DEFAULT.merge(data).transform_keys do |key|
        WEEKDAYS[key.to_i]
      end
    end

    # @param question [Question]
    #
    # @return [Hash{String, Integer}]
    def answer_occurrence(question)
      Perspective::AnswerOccurrence.get(question.question_type).collect(reportable, question)
    end

    # @param question [Question]
    #
    # @return [{ 'Min' => Integer, 'Max' => Integer, 'Sum' => Integer, 'Average' => Float, 'Std. Dev.' => Float }]
    def answer_stats(question)
      Perspective::AnswerStats.get(question.question_type).collect(reportable, question)
    end
  end
end