module Dragnet
  module Types
    class Basic < Type
      def get_value(...)        = Answer::GetValue.new(question, ...)
      def get_number_value(...) = Answer::GetNumberValue.new(question, ...)

      def filter_data_grid(...)    = DataGrid::Filter.new(question, ...)
      def sort_data_grid(...)      = DataGrid::Sort.new(question, ...)
      def render_answers_text(...) = DataGrid::RenderAnswersText.new(question, ...)
      def get_text_alignment(...)  = DataGrid::GetTextAlignment.new(question, ...)

      def countable?
        is_a?(Types::Countable)
      end
    end
  end
end
