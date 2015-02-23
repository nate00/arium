module Arium
  module Creators
    class Village
      include Configurable

      config.rows = 100
      config.columns = 100
      config.villages = 1
      config.lakes = 1

      def create
        Array.new(config.rows) { Array.new(config.columns, 'plain') }.tap do |grid|
          config.lakes.times do
            add_lake!(grid)
          end

          config.villages.times do
            add_village!(grid)
          end
        end
      end

      private

      def add_village!(grid, attempts: 0)
        return if attempts == 10

        nucleus_r = Kernel.rand(config.rows - 1)
        nucleus_c = Kernel.rand(config.columns - 1)

        return add_village!(grid, attempts: attempts + 1) if grid[nucleus_r][nucleus_c] == 'water'

        grid[nucleus_r    ][nucleus_c    ] = 'village'
        grid[nucleus_r    ][nucleus_c + 1] = 'village'
        grid[nucleus_r + 1][nucleus_c    ] = 'farm'
        grid[nucleus_r + 1][nucleus_c + 1] = 'farm'
      end

      def add_lake!(grid)
        center_r = Kernel.rand(config.rows - 1)
        center_c = Kernel.rand(config.columns - 1)

        grid.each.with_index do |row, r|
          row.each.with_index do |cell, c|
            if (r - center_r).abs + (c - center_c).abs <= 10
              grid[r][c] = 'water'
            end
          end
        end
      end
    end
  end
end
