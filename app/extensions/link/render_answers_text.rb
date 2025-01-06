module Dragnet
  module Ext
    class Link::RenderAnswersText < DataGrid::RenderAnswersText
      def link
        tag.div(class: 'text-nowrap') do
          if answers.present?
            answers.each do |answer|
              context.concat tag.a(href: answer.text_value) { answer.text_value }
            end
          else
            alt_text
          end
        end
      end # link
    end # RenderAnswersText
  end
end
