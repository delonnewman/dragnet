module Dragnet
  module Ext
    class Phone::RenderAnswersText < DataGrid::RenderAnswersText
      def phone
        tag.div(class: 'text-nowrap') do
          if answers.present?
            answers.each do |answer|
              context.concat tag.a(href: "tel:#{answer.text_value}") { answer.text_value }
            end
          else
            alt_text
          end
        end
      end # phone
    end # RenderAnswersText
  end
end
