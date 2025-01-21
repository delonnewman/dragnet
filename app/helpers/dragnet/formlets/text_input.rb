module Dragnet
  module Formlets
    class TextInput < InputFormlet
      attribute :label

      def html
        <<~HTML.squish!
          <input
            type="text"
            class="form-control"
            id="#{id}"
            name="#{name}"
            value="#{value}"
            placeholder="#{label}"
            aria-label="#{label}">
        HTML
      end
    end
  end
end
