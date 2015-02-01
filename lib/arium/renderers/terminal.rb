require 'colorize'
module Arium
  module Renderers
    class Terminal
      def render_colors(grid, debug: false)
        grid.map.with_index do |row, row_index|
          row.map.with_index do |cell, col_index|
            str_for(row_index, col_index, debug)
              .colorize(color: :black, background: cell)
          end.join
        end.join("\n")
      end

      private

      def str_for(row, col, debug, base: 10)
        return ' ' unless debug

        # You can find a cell's row by looking to a nearby diagnonal for the
        # ones digit and a nearby column for the tens digit. Similarly, a cell's
        # column can be deduced from a nearby diagonal and row. (Looking at an
        # example is easier than reading the code.)
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
