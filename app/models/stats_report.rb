class StatsReport
  extend Forwardable

  attr_reader :reportable

  def_delegators :reportable, :questions

  def self.from_question_ids(question_ids)
    new(Report.new(question_ids))
  end

  def initialize(reportable)
    @reportable = reportable
  end

  def replies_by_date
    reportable
      .replies
      .group('replies.created_at::date')
      .count
  end

  MONTH_DEFAULT = (1...12).inject({}) { |map, month| map.merge!(month => 0) }.freeze

  def replies_by_month
    data = reportable.replies.group('extract(month from replies.created_at)').count

    MONTH_DEFAULT.merge(data).transform_keys do |key|
      Date::MONTHNAMES[key.to_i]
    end
  end

  TIME_OF_DAY_DEFAULT = (0..23).inject({}) { |map, hr| map.merge!(hr => 0) }.freeze

  def replies_by_time_of_day
    data = reportable.replies.group('extract(hour from replies.created_at)').count

    TIME_OF_DAY_DEFAULT.merge(data).transform_keys do |key|
      Dragnet::TimeUtils.fmt_hour(key.to_i)
    end
  end
end
