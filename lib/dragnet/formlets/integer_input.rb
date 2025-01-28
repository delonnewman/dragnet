module Dragnet
  module Formlets
    class IntegerInput < InputFormlet
      value_type Types::Integer
      attribute :label

      def html
        <<~HTML.squish!
          <input
            type="number"
            class="form-control"
            id="#{id}"
            name="#{name}
            value="#{value}"
            placeholder="#{label}"
            aria-label="#{label}">
        HTML
      end
    end
  end
end
