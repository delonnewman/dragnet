class QuestionType < ApplicationRecord
  include Slugged

  has_many :questions

  def ident
    slug.underscore.to_sym
  end

  all.each do |type|
    define_singleton_method type.ident do
      type
    end
  end
end
