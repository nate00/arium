module Arium
  module Creators
    class Example
      include Configurable

      # Config:
      #   rows
      #   columns

      config.rows = 100
      config.columns = 100

      def create
        Generation.create(config.rows, config.columns, 'plain')
      end
    end
  end
end
