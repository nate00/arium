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
        config.columns.times.map { [:plain] * config.rows }
      end
    end
  end
end
