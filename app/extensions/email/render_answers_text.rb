module Dragnet
  module Ext
    class Email::RenderAnswersText < DataGrid::RenderAnswersText
      def email
        tag.div(class: 'text-nowrap') do
          if answers.present?
            answers.each do |answer|
              context.concat tag.a(href: "mailto:#{answer.text_value}") { answer.text_value }
            end
          else
            alt_text
          end
        end
      end # email
    end # RenderAnswersText
  end
end
