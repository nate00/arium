module Arium
  module Evolvers
    class Water
      def evolve(previous)
        previous.map_generation do |cell, _r, _c|
          if become_water?(cell)
            'water'
          else
            non_water_successor(cell)
          end
        end
      end

      private

      def become_water?(cell)
        probability = 0
        probability += 0.98 if cell.value == 'water'
        probability += 0.02 / 9 * cell.nearby.select { |n, _r, _c| n && (n.value == 'water') }.count
        Kernel.rand < probability
      end

      def non_water_successor(cell)
        if cell.value == 'water'
          'plain'
        else
          cell.value
        end
      end
    end
  end
end
