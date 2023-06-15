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

    htmx_options = { push_url: push_url, get: table_path, target: '#data-grid-table', swap: 'outerHTML' }
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

  # Render a filter control as HTML according to the question type.
  #
  # @param [Question] question
  #
  # @return [String] the corresponding HTML
  def question_filter(question, default_value)
    DataGridFilterInputPerspective.get(question.question_type, self).render(question, default_value)
  end

  # Render the answers to the question as readonly HTML according to their question type.
  #
  # @param [Reply] reply
  # @param [Question] question
  # @param [String] alt
  #
  # @return [String] the corresponding HTML
  def answers_text(reply, question, alt: '-')
    DataGridDisplayPerspective
      .get(question.question_type, self)
      .render(reply.answers_to(question), question, alt: alt)
  end

  # Render the answers to the question as editable HTML inputs according to their question type.
  #
  # @param [Reply] reply
  # @param [Question] question
  #
  # @return [String] the corresponding HTML
  def answers_input(reply, question)
    DataGridEditPerspective.get(question.question_type, self).render(reply.answers_to(question))
  end

  def fmt_date(date)
    date.strftime('%Y-%m-%d')
  end

  def fmt_datetime(date)
    date.strftime('%Y-%m-%d %l:%M %p')
  end
end
