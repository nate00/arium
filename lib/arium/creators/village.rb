module Arium
  module Creators
    class Village
      include Configurable

      config.rows = 100
      config.columns = 100
      config.villages = 1
      config.lakes = 1

      def create
        Generation.create(config.rows, config.columns, 'plain', 0).tap do |generation|
          config.lakes.times do
            add_lake!(generation)
          end

          config.villages.times do
            add_village!(generation)
          end
        end
      end

      private

      def add_village!(generation, attempts: 0)
        return if attempts == 10

        nucleus = generation.cells.sample

        if nucleus.occupant.water?
          return add_village!(generation, attempts: attempts + 1)
        end

        nucleus.occupant = Occ.village
        nucleus.altitude = 30
        [
          generation.neighbor(nucleus, Direction.southeast),
          generation.neighbor(nucleus, Direction.south),
          generation.neighbor(nucleus, Direction.southwest),
        ].compact.each do |neighbor|
          neighbor.occupant = Occ.farm
          neighbor.altitude = 20
        end
      end

      def add_lake!(generation)
        center = generation.cells.sample

        generation.manhattan_nearby(center, distance: 10).each do |nearby|
          nearby.occupant = Occ.water
          nearby.altitude = 10
        end
      end
    end
  end
end
