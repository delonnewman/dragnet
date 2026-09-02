class Dragnet::Value
  # @abstract
  #: () -> String
  def text_value
    raise NoMethodError, "not implemented by #{self.class}, subclasses should implement"
  end

  # @abstract
  #: () -> Numeric
  def number_value
    raise NoMethodError, "not implemented by #{self.class}"
  end

  # @abstract
  #: () -> Hash
  def to_h
    raise NoMethodError, "not implemented by #{self.class}"
  end

  # @abstract
  #: () -> Array
  def to_a
    raise NoMethodError, "not implemented by #{self.class}"
  end

  #: () -> String
  def to_s
    text_value
  end
  alias to_str to_s

  #: () -> Integer
  def to_i
    number_value.to_i
  end

  #: () -> Float
  def to_f
    number_value.to_f
  end

  #: () -> Rational
  def to_r
    number_value.to_r
  end

  #: (untyped) -> bool
  def ==(other)
    return false unless other.is_a?(self.class)

    text_value == other.text_value
  end

  #: () -> Integer
  def hash
    text_value.hash
  end

  #: (untyped) -> bool
  def eql?(other)
    return false unless other.is_a?(self.class)

    super
  end

  #: (untyped) -> bool
  def ===(other)
    text_value == other
  end
end
