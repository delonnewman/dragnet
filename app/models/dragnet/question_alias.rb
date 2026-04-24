module Dragnet
  class QuestionAlias < ActiveRecord::Base
    attribute :name, :string

    belongs_to :reportable, polymorphic: true
    belongs_to :question
  end
end
