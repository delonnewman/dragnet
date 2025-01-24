module Dragnet
  module Formlets
    class DateInput < InputFormlet
      value_type Types::Date
      attribute :label

      def html
        <<~HTML.squish!
          <input
            type="date"
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
