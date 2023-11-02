# frozen_string_literal: true

module Dragnet
  module_function

  UUID_PATTERN = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i

  def uuid?(string)
    return false unless string

    !!(string =~ UUID_PATTERN)
  end
end
