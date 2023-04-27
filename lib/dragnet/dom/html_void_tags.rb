# frozen_string_literal: true

module Dragnet
  module DOM
    module HTMLVoidTags
      extend Tags

      # @!method area(**attributes, &content)
      # 	Outputs an `<area>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/area
      register_void_tag :area, tag: "area"

      # @!method br(**attributes, &content)
      # 	Outputs a `<br>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/br
      register_void_tag :br, tag: "br"

      # @!method embed(**attributes, &content)
      # 	Outputs an `<embed>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/embed
      register_void_tag :embed, tag: "embed"

      # @!method hr(**attributes, &content)
      # 	Outputs an `<hr>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/hr
      register_void_tag :hr, tag: "hr"

      # @!method img(**attributes, &content)
      # 	Outputs an `<img>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/img
      register_void_tag :img, tag: "img"

      # @!method input(**attributes, &content)
      # 	Outputs an `<input>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/input
      register_void_tag :input, tag: "input"

      # @!method link(**attributes, &content)
      # 	Outputs a `<link>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/link
      register_void_tag :link, tag: "link"

      # @!method meta(**attributes, &content)
      # 	Outputs a `<meta>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/meta
      register_void_tag :meta, tag: "meta"

      # @!method param(**attributes, &content)
      # 	Outputs a `<param>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/param
      register_void_tag :param, tag: "param"

      # @!method source(**attributes, &content)
      # 	Outputs a `<source>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/source
      register_void_tag :source, tag: "source"

      # @!method track(**attributes, &content)
      # 	Outputs a `<track>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/track
      register_void_tag :track, tag: "track"

      # @!method col(**attributes, &content)
      # 	Outputs a `<col>` tag.
      # 	@return [HTMLVoidElement]
      # 	@see https://developer.mozilla.org/docs/Web/HTML/Element/col
      register_void_tag :col, tag: "col"
    end
  end
end
