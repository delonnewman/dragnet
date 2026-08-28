class Dragnet::Value
  def text_value
    raise NoMethodError, "not implemented by #{self.class}, subclasses should implement"
  end

  def number_value
    raise NoMethodError, "not implemented by #{self.class}"
  end

  def to_h
    raise NoMethodError, "not implemented by #{self.class}"
  end

  def to_a
    raise NoMethodError, "not implemented by #{self.class}"
  end

  def to_s
    text_value
  end
  alias to_str to_s

  def to_i
    number_value.to_i
  end

  def to_f
    number_value.to_f
  end

  def to_r
    number_value.to_r
  end

  def ==(other)
    return false unless other.is_a?(self.class)

    text_value == other.text_value
  end

  def hash
    text_value.hash
  end

  def eql?(other)
    return false unless other.is_a?(self.class)

    super
  end

  def ===(other)
    text_value == other
  end
end
