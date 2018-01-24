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
        boundary = generation.boundary { |c| c.altitude >= 10 }

        height = generation.row_count * unit
        width = generation.column_count * unit
        with_image(width, height, config.outfile) do |image|
          generation.each do |cell|
            paint(
              image,
              cell,
              generation,
              boundary,
            )
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

      def paint(image, cell, generation, boundary)
        left = cell.col * unit
        right = left + unit
        top = cell.row * unit
        bottom = top + unit
        image.rect(
          left, top, right, bottom,
          ChunkyPNG::Color::TRANSPARENT,
          COLORS.fetch(cell.occupant, 'red')
        )

        return unless boundary.include?(cell)

        mid_x = left + unit / 2
        mid_y = top + unit / 2

        {
          Direction.north => [mid_x, top],
          Direction.east => [right, mid_y],
          Direction.south => [mid_x, bottom],
          Direction.west => [left, mid_y],
        }.each do |direction, coordinates|
          neighbor = generation.neighbor(cell, direction)
          next unless boundary.include?(neighbor)

          image.line(
            *[mid_x, mid_y],
            *coordinates,
            'black'
          )
        end
      end
    end
  end
end
