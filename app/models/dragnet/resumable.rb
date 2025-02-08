module Dragnet
  # Flags a class or object that implements the Resumable protocol
  module Resumable
    def resume_with(_params)
      raise NoMethodError, "Resumable classes must implement resume_with"
    end
  end
end
