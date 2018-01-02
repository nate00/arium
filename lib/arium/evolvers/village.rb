module Arium
  module Evolvers
    class Village
      def evolve(previous_gen)
        previous_gen.map_generation do |cell, r, c|
          case cell.occupant
            when 'plain' then evolve_plain(cell)
            when 'farm' then evolve_farm(cell)
            when 'village' then evolve_village(cell)
            else cell.occupant
          end
        end
      end

      private

      def evolve_plain(cell)
        counts = neighbor_count(cell)
        if counts['village'] >= 1
          'farm'
        else
          'plain'
        end
      end

      def evolve_farm(cell)
        counts = neighbor_count(cell)
        if counts['village'] >= 2
          'village'
        elsif counts['village'] >= 1 || counts['farm'] >= 3
          'farm'
        else
          'plain'
        end
      end

      def evolve_village(cell)
        counts = neighbor_count(cell)
        if counts['farm'] < 1
          'plain'
        else
          'village'
        end
      end

      def neighbor_count(cell)
        h = Hash[
          cell
            .neighbors
            .map { |c, _r, _c| c.occupant }
            .group_by { |occupant| occupant }
            .map { |occupant, arr| [occupant, arr.count] }
        ]
        h.default_proc = proc { 0 }
        h
      end

    end
  end
end
