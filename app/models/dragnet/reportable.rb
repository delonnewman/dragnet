module Dragnet::Reportable
  def self.satisfied_by?(object)
    object.respond_to?(:records) && object.respond_to?(:fields)
  end
end
