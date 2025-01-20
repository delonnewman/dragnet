module Dragnet
  class DoNothing < TypeMethod
    def initialize
      super(nil)
    end

    def dispatch(type); end
  end
end
