# frozen_string_literal: true

# Report stats for a reportable object
class StatsReport
  attr_reader :reportable

  delegate :questions, :name, to: :reportable

  # @param reportable [#replies, #answers]
  def initialize(reportable)
    @reportable = reportable
  end

  # @return [Hash{Date, Integer}]
  def replies_by_date
    reportable
      .replies
      .group('replies.created_at::date')
      .count
  end

  MONTH_DEFAULT = {
    1  => 0,
    2  => 0,
    3  => 0,
    4  => 0,
    5  => 0,
    6  => 0,
    7  => 0,
    8  => 0,
    9  => 0,
    10 => 0,
    11 => 0,
    12 => 0,
  }.freeze

  # @return [Hash{String, Integer}]
  def replies_by_month
    data = reportable.replies.group('extract(month from replies.created_at)').count

    MONTH_DEFAULT.merge(data).transform_keys do |key|
      Date::MONTHNAMES[key.to_i]
    end
  end

  TIME_OF_DAY_DEFAULT = {
    0  => 0,
    1  => 0,
    2  => 0,
    3  => 0,
    4  => 0,
    5  => 0,
    6  => 0,
    7  => 0,
    8  => 0,
    9  => 0,
    10 => 0,
    11 => 0,
    12 => 0,
    13 => 0,
    14 => 0,
    15 => 0,
    16 => 0,
    17 => 0,
    18 => 0,
    19 => 0,
    20 => 0,
    21 => 0,
    22 => 0,
    23 => 0
  }.freeze

  # @return [Hash{String, Integer}]
  def replies_by_time_of_day
    data = reportable.replies.group('extract(hour from replies.created_at)').count

    TIME_OF_DAY_DEFAULT.merge(data).transform_keys do |key|
      Dragnet::TimeUtils.fmt_hour(key.to_i)
    end
  end

  WEEKDAYS = %w[Sun Mon Tue Wed Thu Fri Sat].freeze
  WEEKDAY_DEFAULT = {
    0 => 0,
    1 => 0,
    2 => 0,
    3 => 0,
    4 => 0,
    5 => 0,
    6 => 0
  }.freeze

  # @return [Hash{String, Integer}]
  def replies_by_weekday
    data = reportable.replies.group('extract(dow from replies.created_at)').count

    WEEKDAY_DEFAULT.merge(data).transform_keys do |key|
      WEEKDAYS[key.to_i]
    end
  end

  # @param question [Question]
  #
  # @return [Hash{String, Integer}]
  def answer_occurrence(question)
    opts = question.question_options.inject({}) { |map, opt| map.merge!(opt.id => opt.text) }
    data = reportable.answers.where(question: question).group(:question_option_id).count

    data.transform_keys(&opts)
  end

  # @param question [Question]
  #
  # @return [{ 'Min' => Integer, 'Max' => Integer, 'Sum' => Integer, 'Average' => Float, 'Std. Dev.' => Float }]
  def answer_stats(question)
    weight = question_options[:weight]

    data =
      reportable
        .answers
        .where(question: question)
        .joins(:question_option)
        .pluck(min(weight), max(weight), sum(weight), avg(weight), stddev(weight))
        .first

    project_answer_stats(data)
  end

  private

  def project_answer_stats(data)
    { 'Min'       => data[0].if_nil(0),
      'Max'       => data[1].if_nil(0),
      'Sum'       => data[2].if_nil(0),
      'Average'   => data[3].if_nil(0).round(1),
      'Std. Dev.' => data[4].if_nil(0).round(1) }
  end

  def question_options
    Arel::Table.new(:question_options)
  end

  def min(column)
    Arel::Nodes::NamedFunction.new('min', [column])
  end

  def max(column)
    Arel::Nodes::NamedFunction.new('max', [column])
  end

  def avg(column)
    Arel::Nodes::NamedFunction.new('avg', [column])
  end

  def sum(column)
    Arel::Nodes::NamedFunction.new('sum', [column])
  end

  def stddev(column)
    Arel::Nodes::NamedFunction.new('stddev', [column])
  end
end
