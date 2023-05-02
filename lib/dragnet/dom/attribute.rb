# frozen_string_literal: true

module Dragnet
  module DOM
    # Represents the the attributes of an element
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Attr
    class Attribute < Node
      # Attributes *qualified* name. If the attribute is not in a namespace it will be the same as
      # the local_name attribute.
      # @return [String]
      attr_accessor :name

      # The attribute's value
      attr_accessor :value

      # The attribute's type
      attr_accessor :type

      def initialize(name: nil, value: nil, element: nil, &_)
        super(parent: element, freeze: false, &_)
        @name   ||= name  || EMPTY_STRING
        @value  ||= value || EMPTY_STRING
      end

      def prefix
        name_parts.first
      end

      def local_name
        name_parts.last
      end

      def type
        TYPES.fetch(name, :string)
      end

      private

      def name_parts
        name.split(':')
      end

      TYPES = {
        'hidden' => :boolean,
        'disabled' => :boolean,
        'onabort' => :code,
        'onautocomplete' => :code,
        'onautocompleteerror' => :code,
        'onblur' => :code,
        'oncancel' => :code,
        'oncanplay' => :code,
        'oncanplaythrough' => :code,
        'onchange' => :code,
        'onclick' => :code,
        'onclose' => :code,
        'oncontextmenu' => :code,
        'oncuechange' => :code,
        'ondblclick' => :code,
        'ondrag' => :code,
        'ondragend' => :code,
        'ondragenter' => :code,
        'ondragleave' => :code,
        'ondragover' => :code,
        'ondragstart' => :code,
        'ondrop' => :code,
        'ondurationchange' => :code,
        'onemptied' => :code,
        'onended' => :code,
        'onerror' => :code,
        'onfocus' => :code,
        'oninput' => :code,
        'oninvalid' => :code,
        'onkeydown' => :code,
        'onkeypress' => :code,
        'onkeyup' => :code,
        'onload' => :code,
        'onloadeddata' => :code,
        'onloadedmetadata' => :code,
        'onloadstart' => :code,
        'onmousedown' => :code,
        'onmouseenter' => :code,
        'onmouseleave' => :code,
        'onmousemove' => :code,
        'onmouseout' => :code,
        'onmouseover' => :code,
        'onmouseup' => :code,
        'onmousewheel' => :code,
        'onpause' => :code,
        'onplay' => :code,
        'onplaying' => :code,
        'onprogress' => :code,
        'onratechange' => :code,
        'onreset' => :code,
        'onresize' => :code,
        'onscroll' => :code,
        'onseeked' => :code,
        'onseeking' => :code,
        'onselect' => :code,
        'onshow' => :code,
        'onsort' => :code,
        'onstalled' => :code,
        'onsubmit' => :code,
        'onsuspend' => :code,
        'ontimeupdate' => :code,
        'ontoggle' => :code,
        'onvolumechange' => :code,
        'onwaiting' => :code,
      }.freeze

      private_constant :TYPES
    end
  end
end
