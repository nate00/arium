module Arium
  module Evolvers
    class Village
      def evolve(previous_gen)
        previous_gen = Generation.new(previous_gen)
        ret = previous_gen.map_generation do |cell, r, c|
          adj = adjacent(previous_gen, r, c)
          case previous_gen.at(r, c)
            when 'plain' then evolve_plain(cell, adj)
            when 'farm' then evolve_farm(cell, adj)
            when 'village' then evolve_village(cell, adj)
          end
        end.to_a
        ret
      end

      private

      def evolve_plain(cell, adj)
        if adj['village'] >= 1
          'farm'
        else
          'plain'
        end
      end

      def evolve_farm(cell, adj)
        if adj['village'] >= 2
          'village'
        elsif adj['village'] >= 1 || adj['farm'] >= 3
          'farm'
        else
          'plain'
        end
      end

      def evolve_village(cell, adj)
        if adj['farm'] < 1
          'plain'
        else
          'village'
        end
      end

      def adjacent(generation, r, c)
        h = Hash[
          (-1..1).map do |r_delta|
            (-1..1).map do |c_delta|
              next if r_delta == 0 && c_delta == 0
              generation.at(r + r_delta, c + c_delta)
            end
          end
            .flatten
            .compact
            .group_by { |cell| cell }
            .map { |cell_type, arr| [cell_type, arr.count] }
        ]
        h.default_proc = proc { 0 }
        h
      end

    end
  end
end
