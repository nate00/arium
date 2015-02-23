module Arium
  class Generation
    include Enumerable

    def initialize(array, wrap: false)
      @array = wrap ? wrap(array) : array
    end

    def self.wrap(array)
      new(array, wrap: true)
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
      self.class.wrap result
    end

    def slice(r_start, r_length, c_start, c_length)
      r_start += row_count    if r_start < 0
      c_start += column_count if c_start < 0

      self.class.new(
        Range.new(r_start, r_start + r_length, exclude_end: true).map do |r|
          Range.new(c_start, c_start + c_length, exclude_end: true).map do |c|
            at(r, c)
          end
        end
      )
    end

    def to_a
      @array
    end

    def unwrap
      @array.map do |row|
        row.map do |cell|
          cell.value
        end
      end
    end

    def row_count
      @array.count
    end

    def column_count
      @array.first.count
    end

    def inspect
      "<Generation:#{@array.inspect}>"
    end

    private

    def wrap(raw_array)
      raw_array.map.with_index do |row, r|
        row.map.with_index do |value, c|
          Cell.new(value, self, r, c)
        end
      end
    end
  end
end
