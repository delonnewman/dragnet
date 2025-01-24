module Dragnet
  class ComposedFormlets
    include Enumerable

    def self.with(first, second)
      new(second, new(first, nil))
    end

    def initialize(head, tail)
      @head = head
      @tail = tail
    end

    def last
      @head
    end

    def next
      @tail
    end

    def rest
      @tail || Dragnet::EMPTY_ARRAY
    end

    def each(&)
      rest.each(&)
      yield last
      self
    end

    def *(other)
      ComposedFormlets.new(other, self)
    end

    def html
      map(&:html).join
    end

    def yields(params)
      params.slice(*map(&:name))
    end
  end
end
