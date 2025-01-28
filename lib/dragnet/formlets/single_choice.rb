module Dragnet
  module Formlets
    class SingleChoice < Formlet
      attribute :inputs

      def html
        inputs.join
      end

      def yields(params)
        params.slice(*inputs.map(&:name))
      end
    end
  end
end
