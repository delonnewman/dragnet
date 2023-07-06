# frozen_string_literal: true

class SurveyPresenter < Dragnet::View::Presenter
  include Dragnet::Memoizable

  presents Survey, as: :survey

  def not_ready_for_replies?
    survey.questions.empty?
  end

  def no_data?
    survey.replies.empty? && survey.events.empty?
  end

  def stats_report
    StatsReport.new(survey)
  end
  memoize :stats_report
end
