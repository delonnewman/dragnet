module Dragnet
  class TypeView
    include Memoizable

    FILE_EXTENSIONS = %w(builder erb).freeze

    attr_reader :name, :type

    def initialize(name, type, **locals)
      @name = name
      @type = type
      @locals = locals
    end

    def render_in(view_context)
      view_context.render inline: template, layout: false, type: template_type, locals: @locals
    end

    def template_type
      ext = template_file.extname.presence
      return :erb unless ext

      ext.from(1).to_sym
    end

    def template
      @template ||= template_file.read
    end

    def template_file
      @template_file ||= Pathname.glob(template_glob).first
    end

    def template_glob
      "#{Rails.root}/app/views/#{name}/_{#{type.tags.join(',')}}.html.{#{FILE_EXTENSIONS.join(',')}}"
    end

    def format
      :html
    end
  end
end
