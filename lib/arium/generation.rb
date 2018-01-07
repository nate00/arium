module Arium
  class Generation
    include Enumerable

    def initialize(array, wrap: false)
      @array = wrap ? wrap(array) : array
    end

    def self.wrap(array)
      new(array, wrap: true)
    end

    def self.create(rows, columns, occupant, altitude)
      array = Array.new(rows) do
        Array.new(columns, { occupant: occupant, altitude: altitude })
      end
      self.wrap(array)
    end

    def at(r, c)
      return nil unless include_point?(Point.new(r, c))
      @array[r] && @array[r][c]
    end

    def [](point)
      at(point.row, point.col)
    end

    def include_point?(point)
      point.row.between?(0, row_count - 1) &&
        point.col.between?(0, column_count - 1)
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
            {
              # TODO: Rework +wrap+ to remove the tension between the
              # deserialization case (when we want occupants as Strings) and this
              # case, where we're using it merely as a convenience (and want
              # occupants as Occupants). Then remove this instance_variable_get.
              occupant: yield(cell).instance_variable_get(:@string),
              altitude: cell.altitude,
            }
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
          { occupant: cell.occupant.serialize, altitude: cell.altitude }
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

    def graphical_inspect(*args)
      Renderers::Terminal.with_config(*args).render(self)
    end

    private

    def wrap(raw_array)
      raw_array.map.with_index do |row, r|
        row.map.with_index do |hash, c|
          Cell.new(Occupant.new(hash[:occupant]), hash[:altitude], self, r, c)
        end
      end
    end
  end
end
