class StatsReport
  extend Forwardable

  attr_reader :reportable

  def_delegators :reportable, :questions, :name

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

  WEEKDAY_DEFAULT = (0..6).inject({}) { |map, day| map.merge!(day => 0) }.freeze
  WEEKDAYS = %w[Sun Mon Tue Wed Thu Fri Sat].freeze

  def replies_by_weekday
    data = reportable.replies.group('extract(dow from replies.created_at)').count

    WEEKDAY_DEFAULT.merge(data).transform_keys do |key|
      WEEKDAYS[key.to_i]
    end
  end

  def answer_occurance(question)
    opts = question.question_options.inject({}) { |map, opt| map.merge!(opt.id => opt.text) }
    data = reportable.answers.where(question: question).group(:question_option_id).count

    data.transform_keys(&opts)
  end

  def answer_stats(question)
    weight = question_options[:weight]

    data = reportable
      .answers
      .where(question: question)
      .joins(:question_option)
      .pluck(min(weight), max(weight), sum(weight), avg(weight), stddev(weight))
      .first

    { 'Min'       => data[0],
      'Max'       => data[1],
      'Sum'       => data[2],
      'Average'   => data[3].round(1),
      'Std. Dev.' => data[4].round(1) }
  end

  private

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
