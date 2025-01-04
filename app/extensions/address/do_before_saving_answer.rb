module Dragnet
  module Ext
    class Address::DoBeforeSavingAnswer < Answer::DoBeforeSaving
      def address
        # geo code address and stash lat and long in two float values
      end
    end
  end
end
