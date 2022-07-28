class ActionController::Parameters
  def assert_keys(*keys)
    h = slice(*keys).permit(*keys)
    keys.each do |key|
      raise "missing key `#{key}`" unless h.key?(key)
    end
    h
  end
end

class Hash
  def assert_keys(*keys)
    h = slice(*keys)
    keys.each do |key|
      raise "missing key `#{key}`" unless h.key?(key)
    end
    h
  end
end

class NilClass
  def if_nil(value = self, &block)
    return value unless block_given?

    block.call
  end
end

class Object
  def if_nil(*, &_)
    self
  end
end

class Class
  def presenter?
    false
  end
end
