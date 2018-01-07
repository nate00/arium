module Arium
  class Direction
    attr_reader :row_delta, :col_delta

    def initialize(row_delta, col_delta)
      self.row_delta = row_delta
      self.col_delta = col_delta
    end

    def self.east;      new(0, 1);    end
    def self.northeast; new(-1, 1);   end
    def self.north;     new(-1, 0);   end
    def self.northwest; new(-1, -1);  end
    def self.west;      new(0, -1);   end
    def self.southwest; new(1, -1);   end
    def self.south;     new(1, 0);    end
    def self.southeast; new(1, 1);    end

    private

    def row_delta=(row_delta)
      unless row_delta.is_a?(Numeric)
        raise "row_delta must be a number, got #{row_delta}"
      end
      @row_delta = row_delta
    end

    def col_delta=(col_delta)
      unless col_delta.is_a?(Numeric)
        raise "col_delta must be a number, got #{col_delta}"
      end
      @col_delta = col_delta
    end
  end
end
