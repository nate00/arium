module Arium
  class Cell
    attr_accessor :occupant, :altitude
    attr_accessor :row, :col

    def initialize(occupant, altitude, generation, row, col)
      self.occupant = occupant
      self.altitude = altitude
      @generation = generation
      @row = row
      @col = col
    end

    def neighbor(direction)
      @generation.at(
        @row + direction.row_delta,
        @col + direction.col_delta
      )
    end

    def euclidean_nearby(distance: 1.0)
      @generation.cells.select do |cell|
        euclidean_distance(cell) < distance + 0.00000001
      end
    end

    def euclidean_neighbors(distance: 1.0)
      euclidean_nearby(distance: distance).
        select { |c| c.point != self.point }
    end

    def nearby(distance: 1)
      @generation.slice(
        @row - distance, distance * 2 + 1,
        @col - distance, distance * 2 + 1,
      ).select { |n| n }
    end

    def manhattan_nearby(distance: 1)
      @generation.cells.select do |other|
        manhattan_distance(other) <= distance
      end
    end

    def neighbors(distance: 1)
      nearby(distance: distance).
        select { |c| c.point != self.point }
    end

    def inspect
      "<Cell:#{occupant.inspect}>"
    end

    def euclidean_distance(other)
      safe_sqrt((row - other.row) ** 2 + (col - other.col) ** 2)
    end

    def manhattan_distance(other)
      (row - other.row).abs + (col - other.col).abs
    end

    def point
      Point.new(row, col)
    end

    def occupant=(occupant)
      unless occupant.is_a?(Occupant)
        raise "Argument to occupant= must be an Occupant, instead got #{occupant.inspect}"
      end
      @occupant = occupant
    end

    def altitude=(altitude)
      unless (0..100).include?(altitude)
        raise "Argument to altitude= must be a number between 0 and 100, instead got #{occupant.inspect}"
      end
      @altitude = altitude
    end

    def method_missing(method_name, *args, &block)
      if (m = /occupant_is_(.+)\?/.match(method_name)) && Occupant::VALID_STRINGS.include?(m[1])
        occupant.public_send(:"#{m[1]}?")
      else
        super
      end
    end

    private

    def safe_sqrt(num)
      if num <= 0.0
        0.0
      else
        Math.sqrt(num)
      end
    end
  end
end
