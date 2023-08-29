# frozen_string_literal: true

class Survey::DataGridManagement < Dragnet::Advice
  advises Survey

  def ensure_data_grid!
    survey.data_grid || survey.create_data_grid!
  end

  def ensure_data_grid
    survey.data_grid || survey.build_data_grid
  end
end
