# frozen_string_literal: true

class DataGrid
  extend Dragnet::Advising

  attr_reader :survey

  with FilterRecords, calling: :call

  def initialize(survey)
    @survey = survey
  end
end
