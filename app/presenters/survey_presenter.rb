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

  def share_email?
    share_by?('email')
  end

  def share_qrcode?
    share_by?('qrcode')
  end

  def share_link?
    share_by?('link')
  end

  def share_code?
    share_by?('code')
  end

  def share_by?(method)
    share_method == method
  end

  def share_method
    (params && params[:method]) || 'email'
  end

  def stats_report
    StatsReport.new(survey)
  end
  memoize :stats_report
end
