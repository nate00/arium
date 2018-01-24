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

    def self.delegate_to_grid(method)
      define_method(method) do |*args, &block|
        grid.__send__(method, *args, &block)
      end
    end

    # Delegate methods to +grid+, but convert the result from Points to Cells.
    def self.delegate_to_grid_and_cellify(method)
      define_method(method) do |*args, &block|
        result = grid.__send__(method, *args, &block)

        cellify(result)
      end
    end

    # Delegate methods to +grid+, but convert the result from Points to Cells,
    # and convert the first block argument from a Point to a Cell.
    def self.delegate_to_grid_and_cellify_block(method)
      define_method(method) do |*method_args, &method_block|
        result = grid.__send__(method, *method_args) do |*block_args|
          method_block.call(self[block_args.first], *block_args[1..-1])
        end

        cellify(result)
      end
    end

    def cellify(point_or_points)
      if point_or_points.nil?
        nil
      elsif point_or_points.respond_to?(:row) && point_or_points.respond_to?(:col)
        # Argument is a point.
        self[point_or_points]
      elsif point_or_points.respond_to?(:each)
        # Argument is a point collection, or a collection of nested point
        # collections.
        point_or_points.map { |element| cellify(element) }
      else
        raise "Invalid points: #{point_or_points.class}"
      end
    end

    %i[
      euclidean_distance
      manhattan_distance
    ].each { |method| delegate_to_grid(method) }

    %i[
      neighbor
      euclidean_nearby
      euclidean_neighbors
      manhattan_nearby
      manhattan_neighbors
      nearby
      neighbors
    ].each { |method| delegate_to_grid_and_cellify(method) }

    %i[
      boundary
    ].each { |method| delegate_to_grid_and_cellify_block(method) }

    def at(r, c)
      return nil unless include_point?(Point.new(r, c))
      @array[r] && @array[r][c]
    end

    def [](point)
      at(point.row, point.col)
    end

    def include_point?(point)
      grid.include?(point)
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

    def grid
      Grid.new(row_count, column_count)
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
          Cell.new(Occupant.new(hash[:occupant]), hash[:altitude], r, c)
        end
      end
    end
  end
end
