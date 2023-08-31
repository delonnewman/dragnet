# frozen_string_literal: true

module Dragnet
  class Survey::DataGridManagement < Advice
    advises Survey

    def ensure_data_grid!(user)
      survey.data_grids.find_by(user_id: user.id) || survey.data_grids.create!(user: user)
    end

    def ensure_data_grid(user)
      survey.data_grids.find_by(user_id: user.id) || survey.data_grids.create(user: user)
    end
  end
end