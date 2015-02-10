require 'chunky_png'
module Arium
  module Renderers
    class PNGGrid
      include Persistence

      COLORS = {
        'plain' => 'green',
        'mountain' => 'white',
      }

      UNIT = 10
      OUTFILE = 'outfile.png'

      def render(infile)
        colors =
          read_generation(infile).map do |row|
            row.map do |cell|
              COLORS[cell] || 'red'
            end
          end

        height = colors.size * UNIT
        width = colors.first.size * UNIT
        with_image(width, height, OUTFILE) do |image|
          colors.map.with_index do |row, row_index|
            row.map.with_index do |color, col_index|
              paint(image, color, row_index, col_index)
            end
          end
        end
      end

      private

      def with_image(width, height, filename)
        image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
        yield image
        image.save(filename)
      end

      def paint(image, color, row, col)
        left = col * UNIT
        top = row * UNIT
        image.rect(left, top, left + UNIT, top + UNIT, ChunkyPNG::Color::TRANSPARENT, color)
      end
    end
  end
end
