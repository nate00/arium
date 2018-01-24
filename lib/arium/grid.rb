module Arium
  class Grid
    attr_reader :row_count, :col_count

    def initialize(row_count, col_count)
      @row_count = row_count
      @col_count = col_count
    end

    def include?(point)
      point.row.between?(0, row_count - 1) &&
        point.col.between?(0, col_count - 1)
    end

    def bounded(points)
      if points.respond_to?(:row) && points.respond_to?(:col)
        bounded_point(points)
      else
        bounded_points(points)
      end
    end

    def bounded_point(point)
      if include?(point)
        point
      else
        nil
      end
    end

    def bounded_points(points)
      points.select { |p| include?(p) }
    end

    # is_inside: A block that takes a Point and returns whether that Point is
    #   inside the region.
    #
    # Returns a collection of the points that bound the region.
    #
    def boundary(&is_inside)
      all_points.               # Boundary points:
        select(&is_inside).     #   - Are inside
        select do |point|       #   - Have at least one outside neighbor
          neighbors(point).any? do |neighbor|
            !is_inside.call(neighbor)
          end
        end
    end

    # Returns a collection of Point arrays, each of which represents one
    # connected component. Each component contains points with the same category
    # (as determined by categorizer).
    def components(&categorizer)
      components = {}

      stack = all_points

      while (point = stack.pop)
        next if components.key?(point)

        # Look for an already-componentized neighbor in the same category to
        # join.
        joinable_neighbor = manhattan_neighbors(point).
          select do |n|
            components.key?(n)
          end.select do |n|
            categorizer.call(n) == categorizer.call(point)
          end.first

        joinable_component =
          if joinable_neighbor
            components[joinable_neighbor]
          else
            []
          end

        joinable_component << point
        components[point] = joinable_component

        # Continue exploring into uncomponentized neighbors in the same category.
        # Exploring the entirety of a component before moving onto the next one
        # means we needn't merge components.
        explore_next = manhattan_neighbors(point).
          select do |n|
            !components.key?(n)
          end.select do |n|
            categorizer.call(n) == categorizer.call(point)
          end

        stack.push(*explore_next)
      end

      # We know that there's exactly one array per component, so we can compare
      # them by object_id. The normal hash + eql? comparison is too slow for big
      # arrays.
      components.values.uniq(&:object_id)
    end

    def neighbor(point, direction)
      bounded(Point.new(
        point.row + direction.row_delta,
        point.col + direction.col_delta
      ))
    end

    def euclidean_nearby(center, distance: 1.0)
      all_points.select do |point|
        euclidean_distance(center, point) < distance + 0.00000001
      end
    end

    def euclidean_neighbors(center, distance: 1.0)
      euclidean_nearby(center, distance: distance).
        select { |point| point != center.to_point }
    end

    def nearby(center, distance: 1)
      bounded(
        ((center.row - distance) .. (center.row + distance)).flat_map do |row|
          ((center.col - distance) .. (center.col + distance)).map do |col|
            Point.new(row, col)
          end
        end
      )
    end

    def manhattan_nearby(center, distance: 1)
      nearby(center, distance: distance).select do |point|
        manhattan_distance(center, point) <= distance
      end
    end

    def manhattan_neighbors(center, distance: 1)
      manhattan_nearby(center, distance: distance).
        select { |point| point != center.to_point }
    end

    def neighbors(center, distance: 1)
      nearby(center, distance: distance).
        select { |point| point != center.to_point }
    end

    def euclidean_distance(point_a, point_b)
      safe_sqrt(
        (point_a.row - point_b.row) ** 2 +
        (point_a.col - point_b.col) ** 2
      )
    end

    def manhattan_distance(point_a, point_b)
      (point_a.row - point_b.row).abs +
      (point_a.col - point_b.col).abs
    end

    def all_points
      (0...row_count).flat_map do |row|
        (0...col_count).map do |col|
          Point.new(row, col)
        end
      end
    end

    private

    def safe_sqrt(num)
      if num <= 0.0
        0.0
      else
        Math.sqrt(num)
      end
    end
  end
end
