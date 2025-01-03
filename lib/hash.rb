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
