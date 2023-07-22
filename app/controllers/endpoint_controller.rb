# Controllers that provide front-end API endpoints
class EndpointController < ActionController::API
  include ActionController::MimeResponds

  # TODO: Remove this module and the hook, once security is in place
  include ActionController::RequestForgeryProtection
  ActiveSupport.run_load_hooks(:action_controller_base, self)

  def transit(data)
    io = StringIO.new
    Transit::Writer.new(:json, io).write(data)
    io.string
  end

  def read_transit(io)
    Transit::Reader.new(:json, io).read
  end
end
