# frozen_string_literal: true

class FormType < ApplicationRecord
  include Slugged

  has_many :forms

  serialize :settings
end
