require 'chunky_png'

module Arium
  module Renderers
    class PNGGrid
      include Configurable
      include Persistence

      COLORS = {
        Occ.plain => 'green',
        Occ.mountain => 'white',
        Occ.farm => 'brown',
        Occ.village => 'gray',
        Occ.water => 'blue',
      }

      # Config:
      #   outfile
      #   pixels_per_cell

      config.pixels_per_cell = 10
      config.outfile = 'outfile.png'

      def render_file(infile)
        render(Generation.wrap(read_generation(infile)))
      end

      def render(generation)
        height = generation.row_count * unit
        width = generation.column_count * unit
        with_image(width, height, config.outfile) do |image|
          generation.each do |cell|
            paint_background(image, cell)
          end
          generation.boundaries { |c| c && c.altitude >= 10 }.each do |boundary|
            (boundary + boundary.first(2)).each_cons(3) do |prev, curr, nex|
              paint_contour(image, prev, curr, nex)
            end
          end
        end
      end

      private

      def unit
        config.pixels_per_cell
      end

      def with_image(width, height, filename)
        image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
        yield image
        image.save(filename)
      end

      def paint_background(image, cell)
        square = Square.new(cell, unit)
        image.rect(
          square.left, square.top, square.right, square.bottom,
          ChunkyPNG::Color::TRANSPARENT,
          COLORS.fetch(cell.occupant, 'red')
        )
      end

      def paint_contour(image, prev_cell, curr_cell, next_cell)
        s = Square.new(curr_cell, unit)

        prev_direction = Direction.from(prev_cell, to: curr_cell)
        start_dot =
          if prev_direction == Direction.north
            [s.near_left, s.bottom]
          elsif prev_direction == Direction.east
            [s.left, s.near_top]
          elsif prev_direction == Direction.south
            [s.near_right, s.top]
          elsif prev_direction == Direction.west
            [s.right, s.near_bottom]
          else
            raise "Invalid prev_direction: #{prev_direction}"
          end

        next_direction = Direction.from(curr_cell, to: next_cell)
        finish_dot =
          if next_direction == Direction.north
            [s.near_left, s.top]
          elsif next_direction == Direction.east
            [s.right, s.near_top]
          elsif next_direction == Direction.south
            [s.near_right, s.bottom]
          elsif next_direction == Direction.west
            [s.left, s.near_bottom]
          else
            raise "Invalid next_direction: #{next_direction}"
          end

        image.line(
          *start_dot,
          *finish_dot,
          'black'
        )
      end

    end
  end
end
