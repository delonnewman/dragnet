# frozen_string_literal: true

module DataGridHelper
  # Return an appropriate sort link for this column
  #
  # @param [DataGridPresenter] grid
  # @param [Symbol, Question] column
  #
  # @return [String] the corresponding HTML
  def column_sort_link(grid, column, label:, alt_label: label)
    sorted     = grid.sorted_by_column?(column)
    direction  = sorted ? grid.opposite_sort_direction : grid.default_sort_direction
    push_url   = survey_data_path(grid.survey_id, sort_by: column, sort_direction: direction)
    table_path = survey_data_table_path(grid.survey_id, sort_by: column, sort_direction: direction)

    htmx_options = { push_url: push_url, get: table_path, target: '#data-grid-table', swap: 'morph:innerHTML' }
    html_options = { class: 'btn btn-outline-primary', title: alt_label }

    htmx :button, htmx_options, html_options do
      label.html_safe + ' ' + column_sort_icon(grid, column).html_safe
    end
  end

  # Return the appropriate sort icon for this column
  #
  # @param [DataGridPresenter] grid
  # @param [Symbol, Question] column
  #
  # @return [String] the corresponding HTML
  def column_sort_icon(grid, column)
    if (sorted = grid.sorted_by_column?(column)) && grid.sorted_ascending?
      icon 'fas', 'arrow-up'
    elsif sorted && grid.sorted_descending?
      icon 'fas', 'arrow-down'
    else
      icon 'fas', 'arrows-up-down'
    end
  end

  def data_grid_params
    params.permit(:sort_by, :sort_direction, filter_by: {}).to_h
  end

  # Render a filter control as HTML according to the question type.
  #
  # @param [Question] question
  #
  # @return [String] the corresponding HTML
  def column_filter(question, default_value)
    render Dragnet::TypeView.init('data_grid/column_filter', question.type), locals: { question:, default_value:, data_grid_params: }
  end

  # Render the answers to the question as readonly HTML according to their question type.
  #
  # @param [Reply] reply
  # @param [Question] question
  # @param [String] alt
  #
  # @return [String] the corresponding HTML
  def answers_text(reply, question, alt: '-')
    answers = reply.answers_to(question)
    question.type.send_action(:render_answers_text, context: self, answers:, question:, alt_text: alt) # rescue binding.pry
  end

  def fmt_date(date)
    date.strftime('%Y-%m-%d')
  end

  def fmt_datetime(date)
    date.strftime('%Y-%m-%d %l:%M %p')
  end
end
