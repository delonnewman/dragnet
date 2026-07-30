module Dragnet
  module Ext
    class Address < Types::Text
      perform :do_before_saving_answer, class_name: 'Dragnet::Ext::Address::DoBeforeSavingAnswer'
      perform :render_answers_text, class_name: 'Dragnet::Ext::Address::RenderAnswersText'
    end
  end
end
