module Arium
  module Evolvers
    class Example
      def evolve(previous)
        previous.cells.sample.occupant = 'mountain'
        previous
      end
    end
  end
end
