Dragnet::QuestionType.find_or_create_by!(
  name: 'Email',
  icon: 'fa-regular fa-envelope',
  type_class_name: 'Dragnet::Ext::Email'
)

module Dragnet
  module Ext
    class Email < Type::Text
      ignore :calculate_stats_table, :calculate_occurrence_table

      def get_value(answer:)
        GetValueEmail.new(question_type, answer:)
      end
    end

    class GetValueEmail < Action::GetValue
      def email
        text
      end
    end
  end
end
