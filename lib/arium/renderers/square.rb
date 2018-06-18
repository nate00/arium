# A class that helps render a Cell. It's like a Cell with dimension.

module Arium
  module Renderers
    class Square
      attr_reader :cell
      private
      attr_reader :unit
      public

      def initialize(cell, unit)
        @cell = cell
        @unit = unit
      end

      def top
        cell.row * unit
      end

      def near_top
        top + unit / 3
      end

      def near_bottom
        top + unit * 2 / 3
      end

      def bottom
        top + unit
      end

      def left
        cell.col * unit
      end

      def near_left
        left + unit / 3
      end

      def near_right
        left + unit * 2 / 3
      end

      def right
        left + unit
      end
    end
  end
end
