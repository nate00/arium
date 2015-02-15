module Arium
  class Generation
    include Enumerable

    def initialize(array)
      @array = array
    end

    def at(r, c)
      @array[r] && @array[r][c]
    end

    def each(&block)
      @array.each.with_index do |row, r|
        row.each.with_index do |cell, c|
          yield cell, r, c
        end
      end
    end

    def map_generation
      result = Array.new(@array.size) { Array.new }
      each do |cell, r, c|
        result[r][c] = yield cell, r, c
      end
      self.class.new result
    end

    def to_a
      @array
    end
  end
end
