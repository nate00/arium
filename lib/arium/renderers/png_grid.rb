require 'chunky_png'

module Arium
  module Renderers
    class PNGGrid
      include Persistence

      COLORS = {
        'plain' => 'green',
        'mountain' => 'white',
        'farm' => 'brown',
        'village' => 'gray',
      }

      # Config:
      #   outfile
      #   pixels_per_cell

      config.pixels_per_cell = 10
      config.outfile = 'outfile.png'

      def render(infile)
        colors =
          read_generation(infile).map do |row|
            row.map do |cell|
              COLORS[cell] || 'red'
            end
          end

        height = colors.size * unit
        width = colors.first.size * unit
        with_image(width, height, config.outfile) do |image|
          colors.map.with_index do |row, row_index|
            row.map.with_index do |color, col_index|
              paint(image, color, row_index, col_index)
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

      def paint(image, color, row, col)
        left = col * unit
        top = row * unit
        image.rect(left, top, left + unit, top + unit, ChunkyPNG::Color::TRANSPARENT, color)
      end
    end
  end
end
