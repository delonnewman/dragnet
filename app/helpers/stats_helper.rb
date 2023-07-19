# frozen_string_literal: true

module StatsHelper
  def auto_chart(data)
    if data.size < 5
      pie_chart(data)
    else
      column_chart(data)
    end
  end

  # @param [Hash{Object => Numeric}]
  #
  # @return [String] html string
  def data_table(data, **options)
    tag.table(class: 'table') do
      tag.tbody do
        data.map do |key, value|
          tag.th(key) + tag.td(number_with_delimiter(value, **options))
        end.join(' ').html_safe
      end
    end
  end

  # @param [Numeric, nil] value
  # @param [Hash] options
  #
  # @see NumberHelper#number_with_delimiter for options
  #
  # @return [Numeric, String]
  def stats_value(value, **options)
    return '&mdash;'.html_safe unless value

    number_with_delimiter(value, **options)
  end

  # @param [Numeric, nil] value
  # @param [Hash] options
  #
  # @see NumberHelper#number_to_percentage for options
  #
  # @return [Numeric, String]
  def stats_percentage(value, **options)
    return '&mdash;'.html_safe unless value

    number_to_percentage(value, **options)
  end
end
