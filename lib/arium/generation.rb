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

    def [](point)
      at(point.row, point.col)
    end

    def each
      unless block_given?
        return self.enum_for(__method__)
      end
      @array.each do |row|
        row.each do |cell|
          yield cell
        end
      end
    end

    def map_generation
      self.class.wrap(
        @array.map do |row|
          row.map do |cell|
            yield cell
          end
        end
      )
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
