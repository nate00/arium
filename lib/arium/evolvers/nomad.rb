module Arium
  module Evolvers
    class Nomad
      def evolve(previous_gen)
        agg = Resolver.new(previous_gen, resolver)

        villages(previous_gen).each do |village|
          if starving?(village, previous_gen)
            next
          end

          if quenched?(village, previous_gen)
            if Kernel.rand < 0.10
              new_village = previous_gen.nearby(village).shuffle.first
              agg.add(new_village.point, Occ.village)
              previous_gen.nearby(new_village).each { |n| agg.add(n.point, Occ.farm) }
            end
            previous_gen.nearby(village).each do |neighbor|
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
        direction = average_offset(village, adjacent_farms(village, generation))
        new_village = generation.neighbor(village, direction)
        return unless new_village
        agg.add(new_village.point, Occ.village)

        new_farm = generation.neighbor(new_village, direction)
        return unless new_farm
        generation.nearby(new_village).each do |neighbor|
          if generation.manhattan_distance(neighbor, new_farm) <= 1
            agg.add(neighbor.point, Occ.farm)
          end
        end
      end

      def average_offset(source, destinations)
        Direction.new(
          destinations.map { |dest| dest.row - source.row }.inject(0, :+) <=> 0,
          destinations.map { |dest| dest.col - source.col }.inject(0, :+) <=> 0,
        )
      end

      def adjacent_farms(village, gen)
        gen.nearby(village).select(&:occupant_is_farm?)
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

      def quenched?(village, gen)
        gen.nearby(village).any?(&:occupant_is_water?)
      end

      def starving?(village, gen)
        gen.nearby(village).count < 2
      end

      def villages(generation)
        generation.each.select(&:occupant_is_village?)
      end
    end
  end
end
