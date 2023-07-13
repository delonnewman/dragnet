# frozen_string_literal: true

module StatsHelper
  def auto_chart(data)
    if data.size < 5
      pie_chart(data)
    else
      column_chart(data)
    end
  end

  def data_table(data)
    tag.table(class: 'table') do
      tag.tbody do
        data.map do |key, value|
          tag.th(key) + tag.td(value)
        end.join(' ').html_safe
      end
    end
  end

  # @param [Numeric, nil] value
  # @return [Numeric, String]
  def stats_value(value)
    return '&mdash;'.html_safe unless value

    value
  end

  # @param [Numeric, nil] value
  # @param [Hash] options
  # @return [Numeric, String]
  def stats_percentage(value, **options)
    return '&mdash;'.html_safe unless value

    number_to_percentage(value, **options)
  end
end
