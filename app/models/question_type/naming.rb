module QuestionType::Naming
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

  def is?(ident)
    ident == self.ident
  end
end
