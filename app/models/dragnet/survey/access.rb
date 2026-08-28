class Dragnet::Survey
  module Access
    def opened!
      self.open = true
      self
    end

    def open!
      opened!.tap(&:save!)
    end

    def closed!
      self.open = false
      self
    end

    def close!
      closed!.tap(&:save!)
    end
  end
end
