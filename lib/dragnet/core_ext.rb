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

  def advice?
    false
  end
end
