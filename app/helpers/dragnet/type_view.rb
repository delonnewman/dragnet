module Dragnet
  class TypeView
    include Memoizable

    FILE_EXTENSIONS = %w(builder erb).freeze

    def self.init(*args)
      new(*args)
    end
    memoize self: :init

    attr_reader :name, :type

    def initialize(name, type)
      @name = name
      @type = type
    end

    def render_in(view_context)
      view_context.render file: template_file, layout: false
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
