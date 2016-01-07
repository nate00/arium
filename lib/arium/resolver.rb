require 'pry'
# what should we name this?
#  - Resolver
#  - ForceAggregator
#  - ForceResolver
#  - CellAggregate
module Arium
  class Resolver
    attr_reader :original
    attr_reader :resolver         # { |original_entity, values| new_entity }

    def initialize(original, resolver = nil, &block)
      @original = original
      @resolver = resolver || block
    end

    def add(point, value)
      conflicts[point] << value
    end

    def to_generation
      @original.map_generation do |cell|
        @resolver.call(cell.value, conflicts[cell.point])
      end
    end

    private

    def conflicts
      @conflicts ||= Hash.new { |hash, val| hash[val] = [] }
    end
  end
end
