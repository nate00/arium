module Arium
  class Direction
    attr_reader :row_delta, :col_delta

    def initialize(row_delta, col_delta)
      @row_delta = row_delta
      @col_delta = col_delta
    end

    def self.east;      new(0, 1);    end
    def self.northeast; new(-1, 1);   end
    def self.north;     new(-1, 0);   end
    def self.northwest; new(-1, -1);  end
    def self.west;      new(0, -1);   end
    def self.southwest; new(1, -1);   end
    def self.south;     new(1, 0);    end
    def self.southeast; new(1, 1);    end
  end
end
