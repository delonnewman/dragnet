class YARD::Handlers::Ruby::WithHandler < YARD::Handlers::Ruby::Base
  handles method_call(:with)

  def process
    # pp statement.class
    # pp statement[1]
  end
end
