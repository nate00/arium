module Arium
  module Evolvers
    class Village
      def evolve(previous_gen)
        previous_gen.map_generation do |cell, r, c|
          case cell.occupant
            when Occ.plain then evolve_plain(cell)
            when Occ.farm then evolve_farm(cell)
            when Occ.village then evolve_village(cell)
            else cell.occupant
          end
        end
      end

      private

      def evolve_plain(cell)
        counts = neighbor_count(cell)
        if counts[Occ.village] >= 1
          Occ.farm
        else
          Occ.plain
        end
      end

      def evolve_farm(cell)
        counts = neighbor_count(cell)
        if counts[Occ.village] >= 2
          Occ.village
        elsif counts[Occ.village] >= 1 || counts[Occ.farm] >= 3
          Occ.farm
        else
          Occ.plain
        end
      end

      def evolve_village(cell)
        counts = neighbor_count(cell)
        if counts[Occ.farm] < 1
          Occ.plain
        else
          Occ.village
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
