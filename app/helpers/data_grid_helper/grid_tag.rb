module DataGridHelper
  class GridTag
    def initialize(context, attributes, &)
      @context = context
      @context.concat(@context.content_tag('vaadin-grid', attributes))
      instance_exec(&)
    end

    def column(header, path)
      @context.concat(@context.tag('vaadin-grid-column', header:, path:))
    end
  end
end
