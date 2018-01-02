require 'pry'
# what should we name this?
#  - Resolver
#  - ForceAggregator
#  - ForceResolver
#  - CellAggregate
module Arium
  class Resolver
    attr_reader :original
    attr_reader :resolver         # { |original_occupant, occupants| new_occupant }

    def initialize(original, resolver = nil, &block)
      @original = original
      @resolver = resolver || block
    end

    def add(point, occupant)
      conflicts[point] << occupant
    end

    def to_generation
      @original.map_generation do |cell|
        @resolver.call(cell.occupant, conflicts[cell.point])
      end
    end

    private

    def conflicts
      @conflicts ||= Hash.new { |hash, val| hash[val] = [] }
    end
  end
end
