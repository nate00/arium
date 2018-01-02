module Arium
  module Evolvers
    class Nomad
      def evolve(previous_gen)
        agg = Resolver.new(previous_gen, resolver)

        villages(previous_gen).each do |village|
          if starving? village
            next
          end

          if quenched? village
            if Kernel.rand < 0.10
              new_village = village.nearby.shuffle.first
              agg.add(new_village.point, Occ.village)
              new_village.nearby.each { |n| agg.add(n.point, Occ.farm) }
            end
            village.nearby.each do |neighbor|
              agg.add(neighbor.point, Occ.farm)
            end
            agg.add(village.point, Occ.village)
          else
            migrate!(village, previous_gen, agg)
          end
        end

        agg.to_generation

        # find villages
        # for each village
        #   if starving
        #     die
        #   if dry
        #     find adjacent farms
        #     grow in average direction of adjacent farms
        #     place three farms in direction
        #     die
        #   else
        #     with 5% probability
        #       grow in random direction
        #     place farms everywhere
        #
      end

      def migrate!(village, generation, agg)
        direction = average_offset(village, adjacent_farms(village))
        new_village = Point.new(village.row + direction[0], village.col + direction[1])
        agg.add(new_village, Occ.village)

        new_farm = Point.new(new_village.row + direction[0], new_village.col + direction[1])
        generation[new_village].nearby.each do |neighbor|
          if neighbor.manhattan_distance(new_farm) <= 1
            agg.add(neighbor.point, Occ.farm)
          end
        end
      end

      def average_offset(source, destinations)
        [
          destinations.map { |dest| dest.row - source.row }.inject(:+) <=> 0,
          destinations.map { |dest| dest.col - source.col }.inject(:+) <=> 0,
        ]
      end

      def adjacent_farms(village)
        village.nearby.select(&:occupant_is_farm?)
      end

      def resolver
        proc do |occupant, forces|
          if forces.include?(Occ.village) && [Occ.plain, Occ.farm, Occ.village].include?(occupant)
            Occ.village
          elsif forces.include?(Occ.farm) && [Occ.plain, Occ.farm].include?(occupant)
            Occ.farm
          elsif [Occ.farm, Occ.village].include?(occupant)
            Occ.plain
          else
            occupant
          end
        end
      end

      def quenched?(village)
        village.nearby.any?(&:occupant_is_water?)
      end

      def starving?(village)
        village.nearby.select(&:occupant_is_farm?).count < 2
      end

      def villages(generation)
        generation.each.select(&:occupant_is_village?)
      end
    end
  end
end
