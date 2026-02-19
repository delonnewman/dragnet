module Dragnet
  module Ext
    class Phone::RenderAnswersText < DataGrid::RenderAnswersText
      def phone
        # tag.div(class: 'text-nowrap') do
          if answers.present?
            answers.map do |answer|
              tag.a(href: "tel:#{answer.text_value}") { answer.text_value }
            end.join(' ')
          else
            alt_text
          end
        # end
      end # phone
    end # RenderAnswersText
  end
end
