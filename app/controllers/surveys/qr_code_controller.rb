class Surveys::QRCodeController < SurveysController
  include QRCodeHelper

  def show
    respond_to do |format|
      format.html { render :qrcode, locals: { survey: } }
      format.png  { send_qrcode_data survey, format: :png }
      format.svg  { send_qrcode_data survey, format: :svg }
    end
  end
end
