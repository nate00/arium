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

      # Clumpier cell occupants are more likely to have diagonally adjacent
      # cells rendered contiguously.
      CLUMPINESS = %w[
        plain
        farm
        village
        mountain
        water
      ]

      # Config:
      #   outfile
      #   pixels_per_cell

      config.pixels_per_cell = 10
      config.outfile = 'outfile.png'

      def render(infile)
        cells = read_generation(infile).map do |rows|
          rows.map do |cell|
            cell[:occupant]
          end
        end

        height = cells.size * unit
        width = cells.first.size * unit
        with_image(width, height, config.outfile) do |image|
          cells.map.with_index do |row, row_index|
            row.map.with_index do |cell, col_index|
              northwest = quadrant_occupant(cell,
                [
                  cells[row_index - 1] && cells[row_index - 1][col_index],
                  cells[row_index] && cells[row_index][col_index - 1],
                ],
                cells[row_index - 1] && cells[row_index - 1][col_index - 1],
              )
              northeast = quadrant_occupant(cell,
                [
                  cells[row_index - 1] && cells[row_index - 1][col_index],
                  cells[row_index] && cells[row_index][col_index + 1],
                ],
                cells[row_index - 1] && cells[row_index - 1][col_index + 1],
              )
              southwest = quadrant_occupant(cell,
                [
                  cells[row_index] && cells[row_index][col_index - 1],
                  cells[row_index + 1] && cells[row_index + 1][col_index],
                ],
                cells[row_index + 1] && cells[row_index + 1][col_index - 1],
              )
              southeast = quadrant_occupant(cell,
                [
                  cells[row_index] && cells[row_index][col_index + 1],
                  cells[row_index + 1] && cells[row_index + 1][col_index],
                ],
                cells[row_index + 1] && cells[row_index + 1][col_index + 1],
              )

              puts "#{row_index} #{col_index}"
              paint_quadrant(image, northwest, row_index, col_index, :northwest)
              paint_quadrant(image, northeast, row_index, col_index, :northeast)
              paint_quadrant(image, southwest, row_index, col_index, :southwest)
              paint_quadrant(image, southeast, row_index, col_index, :southeast)
              puts "#{row_index} #{col_index} quad"
              paint_circle(image, cell, row_index, col_index)
              puts "#{row_index} #{col_index} circle"
            end
          end
        end
      end

      private

      def quadrant_occupant(cell, lateral_neighbors, diagonal_neighbor)
        neighbors = lateral_neighbors + [diagonal_neighbor]
        if neighbors.any? { |n| n.nil? }
          cell
        elsif neighbors.all? { |n| n == neighbors.first }
          neighbors.first
        elsif (
            # If both lateral neighbors match, then we should render them as a
            # single clump.
            (contiguous_candidate = lateral_neighbors.first) &&
            lateral_neighbors.all? { |n| n == contiguous_candidate } && (
              # There may be a clump conflict if this cell wants to clump with
              # its diagonal neighbor, and the lateral cells want to clump
              # together. In that case, whichever cells are "clumpier" win.
              diagonal_neighbor != cell ||
              clumpiness(contiguous_candidate) > clumpiness(cell)
            )
        )
          contiguous_candidate
        else
          cell
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

      def paint_quadrant(image, cell, row, col, quadrant)
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

        image.rect(left, top, left + unit / 2, top + unit / 2, ChunkyPNG::Color::TRANSPARENT, color(cell))
      end

      def paint_circle(image, cell, row, col)
        left = col * unit
        top = row * unit
        radius = unit / 2
        image.circle(left + radius, top + radius, radius, ChunkyPNG::Color::TRANSPARENT, color(cell))
      end

      def clumpiness(cell)
        CLUMPINESS.index(cell)
      end

      def color(cell)
        COLORS.fetch(cell, 'red')
      end
    end
  end
end

