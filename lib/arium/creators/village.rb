module Arium
  module Creators
    class Village
      def create
        arr = Array.new(rows) { Array.new(columns, 'plain') }
        nucleus_r = Kernel.rand(rows - 1)
        nucleus_c = Kernel.rand(columns - 1)

        arr[nucleus_r    ][nucleus_c    ] = 'village'
        arr[nucleus_r    ][nucleus_c + 1] = 'village'
        arr[nucleus_r + 1][nucleus_c    ] = 'farm'
        arr[nucleus_r + 1][nucleus_c + 1] = 'farm'

        arr
      end

      def rows
        100
      end

      def columns
        100
      end
    end
  end
end
