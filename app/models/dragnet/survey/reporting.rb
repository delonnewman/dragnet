module Dragnet::Survey::Reporting
  extend ActiveSupport::Concern

  included do
    has_many :records, -> { where(submitted: true) },
             class_name: 'Dragnet::Reply',
             dependent: :restrict_with_error,
             inverse_of: :survey
  end

  def fields = questions
end
