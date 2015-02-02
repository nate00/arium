require 'JSON'

module Arium
  class World
    include Persistence

    def initialize(creator, evolvers)
      @creator = creator
      @evolvers = evolvers
    end

    def first_generation(outfile)
      generation = @creator.create
      write_generation(outfile, generation)
    end

    def next_generation(infile, outfile)
      next_gen = 
        @evolvers.inject(read_generation(infile)) do |prev, evolver|
          evolver.evolve(prev)
        end
      write_generation(outfile, next_gen)
    end
  end
end
