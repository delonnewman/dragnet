class NilClass
  def if_nil(value = self)
    return value unless block_given?

    yield
  end
end

class Object
  def if_nil(*, &_)
    self
  end
end

class Hash
  def transform(&)
    dup.transform!(&)
  end

  def transform!
    each_pair do |key, value|
      store(key, yield(key, value))
    end
  end
end
