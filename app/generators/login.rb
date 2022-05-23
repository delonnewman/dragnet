# frozen_string_literal: true

# Generate a random login
class Login < Dragnet::ParameterizedGenerator
  def initialize(name: nil)
    super()

    @name = name.generate
  end

  def name
    @name || Name.generate
  end

  def call
    Dragnet::Utils.slug(name, delimiter: '_')
  end

  alias to_s call
  alias inspect call
end
