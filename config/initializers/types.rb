require 'dragnet/json_with_symbolized_keys'

ActiveRecord::Type.register(:json_with_symbolized_keys, Dragnet::JsonWithSymbolizedKeys)
