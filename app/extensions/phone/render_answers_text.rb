module Dragnet
  module Ext
    class Phone::RenderAnswersText < DataGrid::RenderAnswersText
      def phone
        tag.div(class: 'text-nowrap') do
          if answers.blank?
            alt_text
          else
            value = answers.first.text_value
            tag.a(href: "tel:#{value}") { value }
          end
        end
      end # phone
    end # RenderAnswersText
  end
end
