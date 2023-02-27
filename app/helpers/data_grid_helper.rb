# frozen_string_literal: true

module DataGridHelper
  # Return an appropriate sort link for this column
  #
  # @param [DataGridPresenter] grid
  # @param [Symbol, Question] column
  def column_sort_link(grid, column)
    sorted = grid.sorted_by_column?(column)
    direction = sorted ? grid.opposite_sort_direction : grid.default_sort_direction

    link_to survey_data_path(grid.survey_id, sort_by: column, sort_direction: direction), class: 'btn btn-outline-secondary btn-sm' do
      column_sort_icon(grid, column)
    end
  end

  # Return the appropriate sort icon for this column
  #
  # @param [DataGridPresenter] grid
  # @param [Symbol, Question] column
  def column_sort_icon(grid, column)
    if (sorted = grid.sorted_by_column?(column)) && grid.sorted_ascending?
      icon 'fas', 'arrow-up'
    elsif sorted && grid.sorted_descending?
      icon 'fas', 'arrow-down'
    else
      icon 'fas', 'arrows-up-down'
    end
  end
end
