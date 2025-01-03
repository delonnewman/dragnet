module Dragnet
  class Action::DoNothing < GenericFunction
    def initialize
      super(nil)
    end

    def send_type(type); end
  end
end
