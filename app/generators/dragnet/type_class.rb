module Dragnet
  module TypeClass
    def self.generate
      registrations.sample.type_class_name.constantize
    end

    def self.registrations
      @registrations ||= TypeRegistration.all.to_a
    end
  end
end
