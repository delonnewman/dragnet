module Dragnet
  class TypeRegistration < ApplicationRecord
    include SelfDescribable

    belongs_to :parent_type, optional: true

    validates :slug, :name, presence: true
    before_validation do
      self.slug = Dragnet::Utils.slug(name) if name && !slug
    end

    def type_class
      type_class_name.constantize
    end

    def fa_icon_class
      meta_data.fetch('fa_icon_class', 'far fa-question')
    end
  end
end
