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

class Hash
  def rename_keys(mapping)
    transform_keys(&mapping)
  end
end
