module Arium
  module Creators
    class Village
      include Configurable

      config.rows = 100
      config.columns = 100
      config.villages = 1
      config.lakes = 1

      def create
        Generation.create(config.rows, config.columns, 'plain').tap do |generation|
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

        if nucleus.occupant == 'water'
          return add_village!(generation, attempts: attempts + 1)
        end

        nucleus.occupant = 'village'
        [
          nucleus.neighbor(Direction.southeast),
          nucleus.neighbor(Direction.south),
          nucleus.neighbor(Direction.southwest),
        ].compact.each do |neighbor|
          neighbor.occupant = 'farm'
        end
      end

      def add_lake!(generation)
        center = generation.cells.sample

        center.manhattan_nearby(distance: 10).each do |nearby|
          nearby.occupant = 'water'
        end
      end
    end
  end
end
