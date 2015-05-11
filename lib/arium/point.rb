module Arium
  class Point
    attr_reader :row, :col

    def initialize(row, col)
      @row, @col = row, col
    end

    def eql?(other)
      id.eql?(other.id)
    end

    def hash
      id.hash
    end

    def id
      [row, col]
    end
  end
end
