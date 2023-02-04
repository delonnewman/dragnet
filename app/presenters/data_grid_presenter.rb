# frozen_string_literal: true

# Presents surveys for the data grid
class DataGridPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  attr_reader :params

  # @param [Survey] survey
  # @param [ActionController::Parameters, Hash] params
  def initialize(survey, params)
    super(survey)
    @params = params
  end

  # @return [ActiveRecord::Relation<Reply>]
  def paginated_records
    @paginated_records ||= survey.replies.offset(pager.offset).limit(pager.items)
  end

  # @return [Pagy]
  def pager
    @pager ||= Pagy.new(count: survey.replies.count, page: page, items: items)
  end

  # @return [Integer]
  def items
    params.fetch(:items, 10)
  end

  # @return [Integer]
  def page
    params.fetch(:page, 1)
  end
end
