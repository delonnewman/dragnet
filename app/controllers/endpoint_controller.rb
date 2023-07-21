# Controllers that provide front-end API endpoints
class EndpointController < ActionController::Base
  include ActionController::MimeResponds

  def transit(data)
    io = StringIO.new
    Transit::Writer.new(:json, io).write(data)
    io.string
  end

  def read_transit(io)
    Transit::Reader.new(:json, io).read
  end
end
