require 'chunky_png'

module Arium
  module Renderers
    class PNGCurves
      include Configurable
      include Persistence

      COLORS = {
        Occ.plain => 'green',
        Occ.mountain => 'white',
        Occ.farm => 'brown',
        Occ.village => 'gray',
        Occ.water => 'blue',
      }

      # Clumpier cell occupants are more likely to have diagonally adjacent
      # cells rendered contiguously.
      CLUMPINESS = [
        Occ.plain,
        Occ.farm,
        Occ.village,
        Occ.mountain,
        Occ.water,
      ]

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
          generation.to_a.each do |row|
            row.each do |cell|
              northwest = quadrant_occupant(cell.occupant,
                [
                  cell.neighbor(Direction.north)&.occupant,
                  cell.neighbor(Direction.west)&.occupant,
                ],
                cell.neighbor(Direction.northwest)&.occupant,
              )
              northeast = quadrant_occupant(cell.occupant,
                [
                  cell.neighbor(Direction.north)&.occupant,
                  cell.neighbor(Direction.east)&.occupant,
                ],
                cell.neighbor(Direction.northeast)&.occupant,
              )
              southwest = quadrant_occupant(cell.occupant,
                [
                  cell.neighbor(Direction.south)&.occupant,
                  cell.neighbor(Direction.west)&.occupant,
                ],
                cell.neighbor(Direction.southwest)&.occupant,
              )
              southeast = quadrant_occupant(cell.occupant,
                [
                  cell.neighbor(Direction.south)&.occupant,
                  cell.neighbor(Direction.east)&.occupant,
                ],
                cell.neighbor(Direction.southeast)&.occupant,
              )

              paint_quadrant(image, northwest, cell.row, cell.col, :northwest)
              paint_quadrant(image, northeast, cell.row, cell.col, :northeast)
              paint_quadrant(image, southwest, cell.row, cell.col, :southwest)
              paint_quadrant(image, southeast, cell.row, cell.col, :southeast)
              paint_circle(image, cell.occupant, cell.row, cell.col)
            end
          end
        end
      end

      private

      def quadrant_occupant(occupant, lateral_neighbors, diagonal_neighbor)
        neighbors = lateral_neighbors + [diagonal_neighbor]
        if neighbors.any? { |n| n.nil? }
          occupant
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
              diagonal_neighbor != occupant ||
              clumpiness(contiguous_candidate) > clumpiness(occupant)
            )
        )
          contiguous_candidate
        else
          occupant
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

      def paint_quadrant(image, occupant, row, col, quadrant)
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

        image.rect(left, top, left + unit / 2, top + unit / 2,
          ChunkyPNG::Color::TRANSPARENT, color(occupant))
      end

      def paint_circle(image, occupant, row, col)
        left = col * unit
        top = row * unit
        radius = unit / 2
        image.circle(left + radius, top + radius, radius,
          ChunkyPNG::Color::TRANSPARENT, color(occupant))
      end

      def clumpiness(occupant)
        CLUMPINESS.index(occupant)
      end

      def color(occupant)
        COLORS.fetch(occupant, 'red')
      end
    end
  end
end

