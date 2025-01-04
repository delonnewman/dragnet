Dragnet::QuestionType.find_or_create_by!(
  name: 'Phone Number',
  slug: 'phone',
  icon: 'fa-regular fa-envelope',
  type_class_name: 'Dragnet::Ext::Phone'
)

module Dragnet
  module Ext
    class Phone < Types::Text
      ignore :calculate_stats_table, :calculate_occurrence_table
      perform :render_answers_text, class_name: 'Dragnet::Ext::Phone::RenderAnswersText'
    end
  end
end