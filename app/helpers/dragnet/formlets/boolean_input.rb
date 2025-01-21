# see https://links-lang.org/quick-help.html#Formlets

module Dragnet
  module Formlets
    class BooleanInput < Formlet
      value_type Types::Boolean
      attribute :label

      def html
        <<~HTML.squish!
          <div class="form-check form-switch">
            <input class="form-check-input" name="#{name}" type="checkbox" role="switch" id="#{id}">
            <label class="form-check-label" for="#{id}">#{label}</label>
          </div>
        HTML
      end
    end
  end
end
