# frozen_string_literal: true

module Dragnet
  module DOM
    class HTMLVoidElement < HTMLElement
      def to_s
        if attributes?
          attr_list = attributes.map { |name, a| "#{name}=#{a.value.to_s.inspect}" }.join(' ')
          "<#{name} #{attr_list}>"
        else
          "<#{name}>"
        end
      end
    end
  end
end
