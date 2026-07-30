module Dragnet
  module Ext
    class Address::RenderAnswersText < DataGrid::RenderAnswersText
      def address
        tag.div(class: 'text-nowrap') do
          if answers.blank?
            alt_text
          else
            answers.detect(&:short_text_value).text_value
          end
        end
      end
    end
  end
end
