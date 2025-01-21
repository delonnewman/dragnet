module Dragnet
  module Formlets
    class MultipleChoice < Formlet
      attribute :choices

      def template
        choices.each_with_index.map do |(choice, value), i|
          <<~HTML
            <div class="form-check">
              <input class="form-check-input" type="check" name="#{name}" value="#{value}" id="#{id}-#{i}">
              <label class="form-check-label" for="#{id}-#{i}">
                #{choice}
              </label>
            </div>
          HTML
        end.join
      end
    end
  end
end
