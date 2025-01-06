module Dragnet
  module Ext
    class Phone < Types::Text
      ignore :calculate_stats_table, :calculate_occurrence_table
      perform :render_answers_text, class_name: 'Dragnet::Ext::Phone::RenderAnswersText'
    end
  end
end
