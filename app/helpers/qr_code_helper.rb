# frozen_string_literal: true

module QRCodeHelper
  # Generate a QR code for the survey if a format is given return the generated data.  If the format is
  # nil (the default) return the RQRCode::QRCode instance.
  #
  # @param [Survey] survey
  # @param [:svg, :png, :html, nil] format
  #
  # @return [String, RQRCode::QRCode]
  def survey_qrcode(survey, format: nil, **options)
    qrcode = RQRCode::QRCode.new(reply_to_url(survey.short_id, survey.slug))

    case format
    when :svg
      qrcode.as_svg(options)
    when :png
      qrcode.as_png(options)
    when :html
      qrcode.as_html
    else
      qrcode
    end
  end

  # @param [Survey] survey
  # @param [:svg, :png, :html] format
  def qrcode_filename(survey, format:)
    "#{survey.slug}-qrcode.#{format}"
  end

  MIME_TYPES = {
    png: 'image/png',
    svg: 'image/svg+xml'
  }.freeze
  private_constant :MIME_TYPES

  # @param [Survey] survey
  # @param [:svg, :png, :html] format
  def send_qrcode_data(survey, format:)
    fmt  = format.to_sym
    mime = MIME_TYPES[fmt]

    send_data survey_qrcode(survey, format: fmt), type: mime, filename: qrcode_filename(survey, format: fmt)
  end
end