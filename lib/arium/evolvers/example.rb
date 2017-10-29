module Arium
  module Evolvers
    class Example
      def evolve(previous)
        previous.cells.sample.value = :mountain
        previous
      end
    end
  end
end
