# frozen_string_literal: true

module SurveysHelper
  include Pagy::Frontend

  def survey_qrcode(survey, **svg_opts)
    RQRCode::QRCode.new(reply_to_url(survey.short_id, survey.slug)).as_svg(svg_opts)
  end
end
