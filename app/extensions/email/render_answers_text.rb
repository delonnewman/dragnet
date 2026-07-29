module Dragnet
  module Ext
    class Email::RenderAnswersText < DataGrid::RenderAnswersText
      def email
        tag.div(class: 'text-nowrap') do
          if answers.blank?
            alt_text
          else
            value = answers.first.text_value
            tag.a(href: "mailto:#{value}") { value }
          end
        end
      end # email
    end # RenderAnswersText
  end
end
