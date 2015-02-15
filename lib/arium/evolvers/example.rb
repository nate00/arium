module Arium
  module Evolvers
    class Example
      def evolve(previous)
        row = previous.sample
        row[Kernel.rand(row.size)] = :mountain
        previous
      end
    end
  end
end
