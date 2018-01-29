# Convenient methods for use at the console. Optimized for writeability, not
# readability.

module Arium
  module Console

    # This method prints a grid of points according to the labelers passed in.
    # See PointLabeler for the labeler interface.
    #
    # Example:
    #
    #   puts Arium::Console.print(
    #     ->(point) { :blue if generation[point].occupant_is_water? },
    #     red: generation.neighbors(some_point),
    #     [:black, "x"] => generation.select(&:occupant_is_mountain?),
    #   )
    #
    def self.print(*nonstandard_labelers)
      labelers = nonstandard_labelers.map { |l| PointLabeler.wrap(l) } + PointLabeler.defaults
      max_row = labelers.map(&:max_row).compact.max
      max_col = labelers.map(&:max_col).compact.max

      (0 .. max_row).map do |r|
        (0 .. max_col).map do |c|
          point = Point.new(r, c)
          labelers.map do |labeler|
            labeler.label(point)
          end.inject(&:reverse_merge)
        end.join
      end.join("\n")
    end

    # A PointLabeler maps points to colors and characters. There
    # are a few ways to represent the same mapping:
    #
    #   PointLabeler.new(Point.new(1,2) => :red)
    #
    #   PointLabeler.new([Point.new(1,2)] => :red)
    #
    #   PointLabeler.new(red: Point.new(1,2))
    #
    #   PointLabeler.new(red: [Point.new(1,2)])
    #
    #   PointLabeler.new(->(point) { :red if point == Point.new(1,2) })
    #
    # A PointLabeler also keeps track of the dimensions of the grid containing
    # the labelled points. You can explicitly set the row and column:
    #   
    #   PointLabeler.new([10, 12])
    #
    #   PointLabeler.new(generation)
    #
    # Labels can be colors, characters, or both:
    #   
    #   PointLabeler.new(red: Point.new(1,2))
    #
    #   PointLabeler.new("x" => Point.new(1,2))
    #
    #   PointLabeler.new(["x", :red] => Point.new(1,2))
    #
    # And this class can treat Directions or Occupants as characters:
    #
    #   PointLabeler.new(Direction.north => Point.new(1,2))
    #
    #   PointLabeler.new(Occupant.plain => Point.new(1,2))
    #
    class PointLabeler
      attr_reader :max_row, :max_col, :labeler
      def self.wrap(arg)
        if arg.is_a?(Hash)
          if arg.empty?
            nil
          elsif (
              (key = arg.first.first) &&
              Array(key).first.respond_to?(:to_point)
            )
            wrap_hash_from_points_to_label(arg)
          else
            wrap_hash_from_label_to_points(arg)
          end
        elsif arg.is_a?(Array) && arg.first.is_a?(Integer)
          wrap_dimensions(*arg)
        elsif arg.respond_to?(:row_count) && arg.respond_to?(:column_count)
          wrap_dimensions(arg.row_count, arg.column_count)
        elsif arg.respond_to?(:call)
          wrap_callable(arg)

        # TODO: If an array of points is passed in, then set dimensions.
        else
          raise "Invalid labeler of class #{arg.class}: #{arg.inspect}"
        end
      end

      def initialize(max_row, max_col, labeler)
        @max_row = max_row
        @max_col = max_col
        @labeler = labeler
      end

      def self.wrap_hash_from_label_to_points(hash)
        hash_from_points_to_label =
          hash.map do |label, points|
            [points, label]
          end.to_h

        wrap_hash_from_points_to_label(hash_from_points_to_label)
      end

      def self.wrap_hash_from_points_to_label(hash)
        hash_with_single_keys =
          hash.flat_map do |points, label|
            Array(points).map do |point|
              [point.to_point, label]
            end
          end.to_h

        max_row = hash_with_single_keys.keys.map(&:row).max
        max_col = hash_with_single_keys.keys.map(&:col).max
        labeler = ->(point) { hash_with_single_keys[point] }

        new(max_row, max_col, labeler)
      end

      def self.wrap_callable(callable)
        new(nil, nil, callable)
      end

      def self.wrap_dimensions(row_count, col_count)
        new(
          row_count - 1,
          col_count - 1,
          ->(_point) { nil },
        )
      end

      def label(point)
        standardize_label(labeler.call(point))
      end

      def self.grid_numbers
        callable = ->(point) do
          # You can find a point's row by looking to a nearby diagnonal for the
          # ones digit and a nearby column for the tens digit. Similarly, a point's
          # column can be deduced from a nearby diagonal and row. Look:
          #
          #  +000000000+111111111+222222222
          #  01........01........01........
          #  0.2.......0.2.......0.2.......
          #  0..3......0..3......0..3......
          #  0...4.....0...4.....0...4.....
          #  0....5....0....5....0....5....
          #  0.....6...0.....6...0.....6...
          #  0......7..0......7..0......7..
          #  0.......8.0.......8.0.......8.
          #  0........90........90........9
          #  +000000000+111111111+222222222
          #  11........11........11........
          #  1.2.......1.2.......1.2.......
          #  1..3......1..3......1..3......
          #  1...4.....1...4.....1...4.....
          #  1....5....1....5....1....5....
          #  1.....6...1.....6...1.....6...
          #  1......7..1......7..1......7..
          #  1.......8.1.......8.1.......8.
          #  1........91........91........9
          #
          base = 10
          if point.row % base == 0 && point.col % base == 0
            '+'                                       # intersection
          elsif point.row % base == 0
            ((point.col / base) % base).to_s(base)    # row
          elsif point.col % base == 0
            ((point.row / base) % base).to_s(base)    # column
          elsif point.row % base == point.col % base
            (point.row % base).to_s(base)             # diagonal
          else
            '.'
          end
        end

        wrap_callable(callable)
      end

      def self.white_background
        callable = ->(_point) { :white }
        wrap_callable(callable)
      end

      def self.empty
        wrap_dimensions(0, 0)
      end

      def self.defaults
        [grid_numbers, white_background, empty]
      end

      def standardize_character(nonstandard)
        if nonstandard.is_a?(Direction)
          direction = nonstandard
          if direction == Direction.north
            "^"
          elsif direction == Direction.west
            "<"
          elsif direction == Direction.south
            "v"
          elsif direction == Direction.east
            ">"
          end
        elsif nonstandard.is_a?(Occupant)
          # Call non-public method
          nonstandard.__send__(:string).each_char.first
        elsif nonstandard.respond_to?(:to_s) && nonstandard.to_s.size == 1
          nonstandard.to_s
        elsif nonstandard.nil?
          nil
        else
          raise "Invalid character: #{nonstandard}"
        end
      end

      def standardize_label(label)
        if label.is_a?(Array) && label.size == 2
          character, color =
            if color?(label.last)
              label
            else
              label.reverse
            end

          Label.new(standardize_character(character), color)
        elsif color?(label)
          Label.new(nil, label)
        else
          Label.new(standardize_character(label), nil)
        end
      end

      def color?(object)
        String.colors.include?(object)
      end

      class Label
        attr_reader :character, :color

        def initialize(character, color)
          @character = character
          @color = color
          validate!
        end

        def validate!
          if character && character.size != 1
            raise "Invalid character: #{character}"
          end

          if color && !String.colors.include?(@color)
            raise "Invalid color: #{color}"
          end
        end

        def reverse_merge(other_label)
          self.class.new(
            character || other_label.character,
            color || other_label.color
          )
        end

        def self.reverse_merge(labels)
          labels.inject(:reverse_merge)
        end

        def to_s
          character.colorize(color)
        end
      end
    end

  end
end
