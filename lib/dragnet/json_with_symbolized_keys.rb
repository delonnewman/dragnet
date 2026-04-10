module Dragnet
  class JsonWithSymbolizedKeys < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Jsonb
    def deserialize(value)
      super&.deep_symbolize_keys
    end

    def cast(value)
      super&.deep_symbolize_keys
    end
  end
end
