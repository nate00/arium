module Arium
  class Cell
    attr_accessor :value

    def initialize(value, generation, r, c)
      self.value = value
      @generation = generation
      @r = r
      @c = c
    end

    def neighbors(distance: 1)
      @generation.slice(
        @r - distance, distance * 2 + 1,
        @c - distance, distance * 2 + 1,
      )
    end

    def inspect
      "<Cell:#{value}>"
    end
  end
end
