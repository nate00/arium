module Arium
  class Cell
    attr_accessor :value
    attr_accessor :row, :col

    def initialize(value, generation, row, col)
      self.value = value
      @generation = generation
      @row = row
      @col = col
    end

    def neighbors(distance: 1)
      @generation.slice(
        @row - distance, distance * 2 + 1,
        @col - distance, distance * 2 + 1,
      ).select { |n| n }
    end

    def inspect
      "<Cell:#{value}>"
    end

    def manhattan_distance(other)
      (row - other.row).abs + (col - other.col).abs
    end

    def point
      Point.new(row, col)
    end
  end
end
