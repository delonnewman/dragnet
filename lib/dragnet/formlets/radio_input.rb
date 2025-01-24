module Dragnet
  module Formlets
    class RadioInput < InputFormlet
      attribute :label
      attribute :checked

      def html
        <<~HTML.squish!
          <div class="form-check">
            <input class="form-check-input" type="radio" #{'checked' if checked} value="#{value}" name="#{name}" id="#{id}">
            <label class="form-check-label" for="#{id}">
              #{label}
            </label>
          </div>
        HTML
      end
    end
  end
end
