module Dragnet
  module Ext
    class Link < Types::Text
      ignore :calculate_stats_table, :calculate_occurrence_table
      perform :render_answers_text, class_name: 'Dragnet::Ext::Link::RenderAnswersText'
    end
  end
end
