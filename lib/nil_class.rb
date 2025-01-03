class NilClass
  def if_nil(value = self)
    return value unless block_given?

    yield
  end
end
