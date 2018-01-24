module Arium
  class Point
    attr_reader :row, :col

    def initialize(row, col)
      @row, @col = row, col
    end

    def ==(other)
      self.id == other.id
    end

    def eql?(other)
      self == other
    end

    def hash
      id.hash
    end

    def id
      [row, col]
    end

    def to_point
      self
    end

    def inspect
      "(#{row}, #{col})"
    end

    def to_s
      inspect
    end
  end
end
