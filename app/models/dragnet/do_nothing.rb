module Dragnet
  class DoNothing < TypeMethod
    def initialize
      super(nil)
    end

    def send_type(type); end
  end
end
