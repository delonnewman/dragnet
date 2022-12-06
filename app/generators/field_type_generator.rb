class FieldTypeGenerator < Dragnet::ActiveRecordGenerator
  TYPES = FieldType.all.to_a

  def call(*)
    TYPES.sample
  end
end
