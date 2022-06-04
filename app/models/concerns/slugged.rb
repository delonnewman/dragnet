# Models that have a slug that is automatically generated from it's name.
# Cached lookup is provided with named class methods.
module Slugged
  extend ActiveSupport::Concern

  class_methods do
    def slugs
      all.map(&:slug)
    end

    def idents
      all.map(&:ident)
    end
  end

  included do
    after_initialize do
      self.slug = Dragnet::Utils.slug(name) if name && !slug
    end

    all.each do |obj|
      define_singleton_method obj.ident do
        obj
      end
    end
  end

  def ident
    slug.underscore.to_sym
  end
end
