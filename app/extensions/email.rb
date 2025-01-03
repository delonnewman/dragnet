Dragnet::QuestionType.find_or_create_by!(
  name: 'Email',
  icon: 'fa-regular fa-envelope',
  type_class_name: 'Dragnet::Ext::Email'
)

module Dragnet
  module Ext
    class Email < Types::Text
      ignore :calculate_stats_table, :calculate_occurrence_table
    end
  end
end
