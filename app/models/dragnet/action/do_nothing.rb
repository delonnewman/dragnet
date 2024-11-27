module Dragnet
  class Action::DoNothing < Action
    def initialize
      super(nil)
    end

    def send_type(type); end
  end
end
