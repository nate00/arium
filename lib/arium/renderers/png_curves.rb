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

      def render(gen)
        height = gen.row_count * unit
        width = gen.column_count * unit
        with_image(width, height, config.outfile) do |image|
          gen.each do |cell|
            paint_occupant(image, cell, gen)
          end
          gen.boundaries { |c| c && c.altitude >= 10 }.each do |boundary|
            (boundary + boundary.first(2)).each_cons(3) do |prev, curr, nex|
              paint_contour(image, prev, curr, nex)
            end
          end
        end
      end

      private

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


        curve_size = unit / 3



        image.line(
          *start_dot,
          *finish_dot,
          'black'
        )
      end

      def paint_occupant(image, cell, gen)
        northwest = quadrant_occupant(cell.occupant,
          [
            gen.neighbor(cell, Direction.north)&.occupant,
            gen.neighbor(cell, Direction.west)&.occupant,
          ],
          gen.neighbor(cell, Direction.northwest)&.occupant,
        )
        northeast = quadrant_occupant(cell.occupant,
          [
            gen.neighbor(cell, Direction.north)&.occupant,
            gen.neighbor(cell, Direction.east)&.occupant,
          ],
          gen.neighbor(cell, Direction.northeast)&.occupant,
        )
        southwest = quadrant_occupant(cell.occupant,
          [
            gen.neighbor(cell, Direction.south)&.occupant,
            gen.neighbor(cell, Direction.west)&.occupant,
          ],
          gen.neighbor(cell, Direction.southwest)&.occupant,
        )
        southeast = quadrant_occupant(cell.occupant,
          [
            gen.neighbor(cell, Direction.south)&.occupant,
            gen.neighbor(cell, Direction.east)&.occupant,
          ],
          gen.neighbor(cell, Direction.southeast)&.occupant,
        )

        paint_quadrant(image, northwest, cell.row, cell.col, :northwest)
        paint_quadrant(image, northeast, cell.row, cell.col, :northeast)
        paint_quadrant(image, southwest, cell.row, cell.col, :southwest)
        paint_quadrant(image, southeast, cell.row, cell.col, :southeast)
        paint_circle(image, cell.occupant, cell.row, cell.col)
      end

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

