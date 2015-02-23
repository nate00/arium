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
      }

      # Config:
      #   numbered_cells
      #   whiny_unrecognized

      config.numbered_cells = true
      config.whiny_unrecognized = true

      def render(infile)
        colors =
          read_generation(infile).map do |row|
            row.map do |cell|
              COLORS[cell] || unrecognized(cell)
            end
          end

        puts render_colors(colors, debug: config.numbered_cells)
      end

      private

      def render_colors(grid, debug: false)
        grid.map.with_index do |row, row_index|
          row.map.with_index do |cell, col_index|
            str_for(row_index, col_index, debug)
              .colorize(color: :black, background: cell)
          end.join
        end.join("\n")
      end

      def unrecognized(cell)
        if config.whiny_unrecognized
          raise RuntimeError, "Unrecognized: #{cell}"
        else
          :red
        end
      end

      def str_for(row, col, debug, base: 10)
        return ' ' unless debug

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
      end
    end
  end
end
