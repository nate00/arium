require 'chunky_png'

module Arium
  module Renderers
    class PNGCurves
      include Configurable
      include Persistence

      COLORS = {
        'plain' => 'green',
        'mountain' => 'white',
        'farm' => 'brown',
        'village' => 'gray',
        'water' => 'blue',
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
              northwest = quadrant_color(color,
                [
                  colors[row_index - 1] && colors[row_index - 1][col_index - 1],
                  colors[row_index - 1] && colors[row_index - 1][col_index],
                  colors[row_index] && colors[row_index][col_index - 1],
                ]
              )
              northeast = quadrant_color(color,
                [
                  colors[row_index - 1] && colors[row_index - 1][col_index],
                  colors[row_index - 1] && colors[row_index - 1][col_index + 1],
                  colors[row_index] && colors[row_index][col_index + 1],
                ]
              )
              southwest = quadrant_color(color,
                [
                  colors[row_index] && colors[row_index][col_index - 1],
                  colors[row_index + 1] && colors[row_index + 1][col_index - 1],
                  colors[row_index + 1] && colors[row_index + 1][col_index],
                ]
              )
              southeast = quadrant_color(color,
                [
                  colors[row_index] && colors[row_index][col_index + 1],
                  colors[row_index + 1] && colors[row_index + 1][col_index],
                  colors[row_index + 1] && colors[row_index + 1][col_index + 1],
                ]
              )

              puts "#{row_index} #{col_index}"
              paint_quadrant(image, northwest, row_index, col_index, :northwest)
              paint_quadrant(image, northeast, row_index, col_index, :northeast)
              paint_quadrant(image, southwest, row_index, col_index, :southwest)
              paint_quadrant(image, southeast, row_index, col_index, :southeast)
              puts "#{row_index} #{col_index} quad"
              paint_circle(image, color, row_index, col_index)
              puts "#{row_index} #{col_index} circle"
            end
          end
        end
      end

      private

      def quadrant_color(color, neighbors)
        if neighbors.any? { |n| n.nil? }
          color
        elsif neighbors.all? { |n| n == neighbors.first }
          neighbors.first
        else
          color
        end
      end

      def unit
        config.pixels_per_cell
      end

      def with_image(width, height, filename)
        image = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
        yield image
        image.save(filename)
      end

      def paint_quadrant(image, color, row, col, quadrant)
        west = col * unit
        east = west + unit / 2
        north = row * unit
        south = north + unit / 2
        left, top =
          if quadrant == :northwest
            [west, north]
          elsif quadrant == :northeast
            [east, north]
          elsif quadrant == :southwest
            [west, south]
          elsif quadrant == :southeast
            [east, south]
          end

        image.rect(left, top, left + unit / 2, top + unit / 2, ChunkyPNG::Color::TRANSPARENT, color)
      end

      def paint_circle(image, color, row, col)
        left = col * unit
        top = row * unit
        radius = unit / 2
        image.circle(left + radius, top + radius, radius, ChunkyPNG::Color::TRANSPARENT, color)
      end
    end
  end
end

