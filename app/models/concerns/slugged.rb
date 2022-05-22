# Models that have a slug that is automatically generated
# from it's name. Cached lookup is provided with the `.[]`
# class method.
module Slugged
  extend ActiveSupport::Concern

  class_methods do
    def [](ident)
      @types ||= {}
      return @types[ident] if @types.key?(ident)

      slug = (ident.is_a?(Symbol) ? ident.name : ident.to_s).dasherize
      @types[ident] = find_by!(slug: slug)
    end

    def slugs
      all.map(&:slug)
    end

    def idents
      all.map(&:ident)
    end
  end

  included do
    before_save do
      self.slug = Dragnet::Utils.slug(name) if name && !slug
    end
  end

  def ident
    slug.underscore.to_sym
  end
end
