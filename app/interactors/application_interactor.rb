# frozen_string_literal: true

class ApplicationInteractor
  include Interactor

  delegate :fail!, to: :context
end
