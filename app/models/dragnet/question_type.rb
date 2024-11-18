# frozen_string_literal: true

module Dragnet
  class QuestionType < ApplicationRecord
    include SelfDescribable

    has_many :questions, class_name: 'Dragnet::Question', dependent: :restrict_with_error, inverse_of: :question_type
    delegate :to_s, to: :name

    validates :slug, :name, presence: true
    before_validation do
      self.slug = Dragnet::Utils.slug(name) if name && !slug
    end

    def self.get(ident)
      find_by(slug: ident)
    end
    memoize self: :get

    def self.slugs
      all.map(&:slug)
    end

    def self.idents
      all.map(&:ident)
    end

    def setting_default(setting)
      settings&.dig(setting, :default)
    end

    def ident
      slug.underscore.to_sym
    end

    def is?(ident)
      ident == self.ident
    end

    # Dispatch extensible actions by type
    def perform(action)
      action.send_type(self)
    end
  end
end
