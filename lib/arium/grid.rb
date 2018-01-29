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

    # Returns an array of paths, where each path traverses a boundary of a
    # region defined by is_inside.
    #
    #
    # ## Directionality
    #
    # You can traverse a boundary in two different directions. Here we adopt
    # the convention that boundaries are left-hugging. Thus, external boundaries
    # go clockwise and internal boundaries go counterclockwise.
    #
    # If we take the following region, with inside points labelled "i":
    #
    #   ........
    #   .iiiiii.
    #   .iiiiii.
    #   .ii..ii.
    #   .iiiiii.
    #   .iiiiii.
    #   ........
    #
    # then there's one external boundary that goes clockwise:
    #
    #   ........
    #   .XX>>XX.
    #   .X....X.
    #   .X....X.
    #   .X....X.
    #   .XX<<XX.
    #   ........
    #
    # and one internal boundary that goes counterclockwise:
    #
    #   ........
    #   ........
    #   ..X<<X..
    #   ..X..X..
    #   ..X>>X..
    #   ........
    #   ........
    #
    def boundaries(&is_inside)
      boundaries = []

      all_points.
        select(&is_inside).
        each do |first_point|
          outside_neighbors = manhattan_neighbors(first_point).reject(&is_inside)

          if outside_neighbors.empty?
            next    # Not a boundary point.
          end

          # Special-case single-point regions because the algorithm below
          # requires a second boundary point.
          if outside_neighbors.size == 4
            boundaries << boundary_starting_at(
              first_point,
              Direction.north,
              &is_inside
            )

            next
          end

          outside_neighbors.each do |outside_neighbor|
            path_direction = Direction.
              from(first_point, to: outside_neighbor).
              turn(:right)
            second_point = advance(first_point, path_direction)
            if is_inside.(second_point)
              boundaries <<
                boundary_starting_at(first_point, path_direction, &is_inside)
            end
          end
        end

      boundaries.uniq do |boundary|
        # A boundary is uniquely identified by its first two points.
        first = boundary.min_by(&:id)   # Any consistent way of choosing the first point is fine.
        second = boundary[(boundary.index(first) + 1) % boundary.size]

        [first.id, second.id]
      end
    end

    private def
    boundary_starting_at(starting_point, starting_direction, &is_inside)
      # The boundary-finding algorithm below becomes uglier if we need to handle
      # the case where the bounded region is a single point. So instead we handle
      # that case separately.
      if manhattan_neighbors(starting_point).none?(&is_inside)
        return [starting_point]
      end

      path = [starting_point]
      point = starting_point
      direction = starting_direction

      loop do
        next_point = advance(point, direction)
        if is_inside.(next_point)
          path << next_point
          point = next_point
          direction = direction.turn(:left)
        else
          direction = direction.turn(:right)
        end

        # We've completed the path once we return to the start moving in the same
        # direction we started in. If we return to the start in the opposite
        # direction, we may just be at a thin part of the region:
        #
        #   .....
        #   .iIi.
        #   .....
        #
        # The path will go through "I" twice, once westward and once eastward.
        #
        break if point == starting_point && direction == starting_direction
      end

      # Drop the last, repeated point
      path[0 ... -1]
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
    alias_method :advance, :neighbor

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
