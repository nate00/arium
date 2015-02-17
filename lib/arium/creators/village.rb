module Arium
  module Creators
    class Village

      # Config:
      #   rows
      #   columns

      config.rows = 100
      config.columns = 100

      def create
        arr = Array.new(config.rows) { Array.new(config.columns, 'plain') }
        nucleus_r = Kernel.rand(config.rows - 1)
        nucleus_c = Kernel.rand(config.columns - 1)

        arr[nucleus_r    ][nucleus_c    ] = 'village'
        arr[nucleus_r    ][nucleus_c + 1] = 'village'
        arr[nucleus_r + 1][nucleus_c    ] = 'farm'
        arr[nucleus_r + 1][nucleus_c + 1] = 'farm'

        arr
      end
    end
  end
end
