module Dragnet
  # Flags that a class or object implements the Resumable protocol
  module Resumable
    def resume_with(_continuation)
      raise NoMethodError, "Resumable classes must implement resume_with"
    end
  end
end
