class FieldOptionAnswer < Dragnet::ParameterizedGenerator
  attr_reader :field

  delegate :field_type, to: :field

  def initialize(field)
    super()

    @field = field
  end

  def field_options
    @field_options ||= field.field_options.to_a
  end

  def call(*)
    case field_type.ident
    when :choice
      field_options.sample
    end
  end
end
