module Dragnet
  module Ext
    class Link::RenderAnswersText < DataGrid::RenderAnswersText
      def link
        tag.div(class: 'text-nowrap') do
          if answers.blank?
            alt_text
          else
            value = answers.first.text_value
            tag.a(href: value) { value }
          end
        end
      end # link
    end # RenderAnswersText
  end
end
