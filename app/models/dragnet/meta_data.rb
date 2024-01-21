# frozen_string_literal: true

module Dragnet
  # A proxy for collected MetaDatum records and their life-cycle
  class MetaData
    delegate :each, :include?, :key?, :keys, :values, :empty?, :to_a, to: :data

    def initialize(self_describable)
      @self_describable = self_describable
      @data = self_describable.meta_data.freeze || EMPTY_HASH
    end

    def to_s
      "#<#{self.class} #{data}>"
    end
    alias inspect to_s

    def [](key)
      data[normalize_key(key)]
    end

    def fetch(key, ...)
      data.fetch(normalize_key(key), ...)
    end

    def data
      return @data if @data

      @data = reload_data
    end
    alias to_h data

    def reset_cache!
      @data = nil
    end

    def add!(key, value)
      update_data!(data.merge(key => value))
    end
    alias []= add!

    def add(key, value)
      update_data(data.merge(key => value))
    end

    def remove!(key)
      update_data!(data.except(normalize_key(key)))
    end

    def remove(key)
      update_data(data.except(normalize_key(key)))
    end

    def update_data!(data)
      @self_describable.meta_data = data
      @self_describable.save!
      reset_cache!
      self
    end
    alias data= update_data!

    def update_data(data)
      @self_describable.meta_data = data
      return false unless @self_describable.save

      reset_cache!
      true
    end

    private

    def reload_data
      @self_describable.reload.meta_data.freeze
    end

    def normalize_key(key)
      key.is_a?(Symbol) ? key.name : key
    end
  end
end
