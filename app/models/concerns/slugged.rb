module Slugged
  extend ActiveSupport::Concern

  included do
    before_save do
      self.slug = Dragnet::Utils.slug(name) if name && !slug
    end
  end
end
