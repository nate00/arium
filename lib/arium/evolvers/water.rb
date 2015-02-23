module Arium
  module Evolvers
    class Water
      include EvolverUtils

      def evolve_generation(previous)
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
        probability += 0.95 if cell.value == 'water'
        probability += 0.05 / 9 * cell.neighbors.select { |n, _r, _c| n && (n.value == 'water') }.count
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
