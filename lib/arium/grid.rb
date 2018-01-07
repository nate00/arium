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
      all_points.select do |point|
        manhattan_distance(center, point) <= distance
      end
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
