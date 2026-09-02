# frozen_string_literal: true

module Dragnet
  # A proxy for meta data and their life-cycle
  class MetaData
    attr_reader :prefix #: Symbol

    delegate :include?, :key?, :keys, :values, to: :data
    delegate :each, :empty?, :[], :fetch, :to_a, to: :data

    delegate :new_record?, :persisted?, to: :@self_describable

    def initialize(self_describable, prefix: nil)
      @mutex = Mutex.new
      @self_describable = self_describable
      @data = load_data
      @prefix = prefix
    end

    def to_s
      "#<#{self.class} #{data}>"
    end
    alias inspect to_s

    def data
      return @data if @data

      @mutex.synchronize do
        @data = load_data(reload: true)
      end
    end
    alias to_h data

    def reset_cache!
      @mutex.synchronize do
        @data = nil
      end
    end

    def add!(key, value)
      update_data!(data.merge(key => value))
    end
    alias []= add!

    def add(key, value)
      update_data(data.merge(key => value))
    end

    def remove!(key)
      update_data!(data.except(key))
    end

    def remove(key)
      update_data(data.except(key))
    end

    def update_data!(data)
      assign_data(data)

      if persisted?
        @self_describable.save!
        reset_cache!
      end

      self
    end
    alias data= update_data!

    def update_data(data)
      assign_data(data)

      if new_record?
        return true
      elsif persisted? && @self_describable.save
        reset_cache!
        return true
      end

      false
    end

    private

    def assign_data(data)
      @mutex.synchronize do
        if @prefix
          @self_describable.meta_data ||= {}
          @self_describable.meta_data[@prefix] = data
        else
          @self_describable.meta_data = data
        end
      end
    end
    
    def load_data(reload: false)
      @self_describable.reload if persisted? && reload

      data = @self_describable.meta_data
      return EMPTY_HASH unless data

      data.deep_symbolize_keys!.freeze
      return data unless @prefix

      data.fetch(@prefix)
    end
  end
end
