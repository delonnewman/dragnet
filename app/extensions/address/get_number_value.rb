module Dragnet::Ext
  class Address::GetNumberValue < Dragnet::Answer::GetNumberValue
    def address
      answer.float_value
    end
  end
end
