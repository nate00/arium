require 'colorize'
module Arium
  module Renderers
    class Terminal
      include Configurable
      include Persistence

      COLORS = {
        'plain' => :green,
        'mountain' => :white,
        'farm' => :light_red,
        'village' => :gray,
        'water' => :blue,
        'void' => :white,
        'antivoid' => :light_gray,
      }

      # Config:
      #   characters - :grid_numbers, :altitude, or :none
      #   whiny_unrecognized - boolean

      config.characters = :grid_numbers
      config.whiny_unrecognized = true

      def render(infile)
        puts render_grid(read_generation(infile))
      end

      private

      def render_grid(grid)
        grid.map.with_index do |row, row_index|
          row.map.with_index do |cell, col_index|
            render_cell(row_index, col_index, cell)
          end.join
        end.join("\n")
      end

      def render_cell(row, col, cell)
        character = character_for(row, col, cell)
        color = COLORS.fetch(cell[:occupant]) { |occ| unrecognized(occ) }

        character.colorize(color: :black, background: color)
      end

      def unrecognized(cell)
        if config.whiny_unrecognized
          raise RuntimeError, "Unrecognized: #{cell.inspect}"
        else
          :red
        end
      end

      def character_for(row, col, cell, base: 10)
        case config.characters
        when :none then ' '
        when :grid_numbers
          # You can find a cell's row by looking to a nearby diagnonal for the
          # ones digit and a nearby column for the tens digit. Similarly, a cell's
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
          if row % base == 0 && col % base == 0
            '+'                                 # intersection
          elsif row % base == 0
            ((col / base) % base).to_s(base)    # row
          elsif col % base == 0
            ((row / base) % base).to_s(base)    # column
          elsif row % base == col % base
            (row % base).to_s(base)             # diagonal
          else
            '.'
          end
        when :altitude
          (cell[:altitude] / 10).to_s
        else
          raise "Invalid config.characters: #{config.characters}"
        end
      end
    end
  end
end
