module Dragnet
  module Ext
    class Address < Types::Text
      perform :do_before_saving_answer, class_name: 'Dragnet::Ext::Address::DoBeforeSavingAnswer'
    end
  end
end
