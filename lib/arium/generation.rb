module Arium
  class Generation
    include Enumerable

    def initialize(array, wrap: false)
      @array = wrap ? wrap(array) : array
    end

    def self.wrap(array)
      new(array, wrap: true)
    end

    def self.create(rows, columns, occupant)
      array = Array.new(rows) { Array.new(columns, occupant) }
      self.wrap(array)
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
            # TODO: Rework +wrap+ to remove the tension between the
            # deserialization case (when we want occupants as Strings) and this
            # case, where we're using it merely as a convenience (and want
            # occupants as Occupants). Then remove this instance_variable_get.
            yield(cell).instance_variable_get(:@string)
          end
        end
      )
    end

    def transform_cells(cells = nil, &block)
      transform_all_cells = cells.nil?
      points = cells.map(&:point) unless transform_all_cells

      map_generation do |cell|
        if transform_all_cells || points.include?(cell.point)
          yield cell
        else
          cell.occupant
        end
      end
    end

    def transform
      yield self
    end

    def maybe_transform(probability, &block)
      if Kernel.rand < probability
        transform(&block)
      else
        self
      end
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

    def cells
      to_a.flatten
    end

    def to_a
      @array
    end

    # TODO: Pick a consistent vocabulary: "unwrap" or "serialize."
    def unwrap
      @array.map do |row|
        row.map do |cell|
          cell.occupant.serialize
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
        row.map.with_index do |occupant_str, c|
          Cell.new(Occupant.new(occupant_str), self, r, c)
        end
      end
    end
  end
end
