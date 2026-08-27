module Dragnet::Components
  class IconButton < Base
    include Phlex::Rails::Helpers::ButtonTo

    def initialize(label:, path: nil, icon:, icon_type: 'fas', method: :post, **html_options)
      @label        = label
      @path         = path
      @icon         = icon
      @icon_type    = icon_type
      @method       = method
      @html_options = html_options
    end

    def view_template
      button_to @path, method: @method, **@html_options do
        render Icon[@icon_type, @icon]
        if @label
          whitespace
          plain @label
        end
      end
    end
  end
end
