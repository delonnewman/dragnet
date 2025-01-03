module Dragnet
  class DoNothing < GenericFunction
    def initialize
      super(nil)
    end

    def send_type(type); end
  end
end
