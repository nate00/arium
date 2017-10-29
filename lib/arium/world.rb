require 'JSON'

module Arium
  class World
    include Persistence
    include Configurable

    config_accessor :creator, :evolvers

    # Config:
    #   creator
    #   evolvers
    #   generation_locator

    def first_generation(outfile)
      generation = creator.create
      write_generation(outfile, generation)
      outfile
    end

    def next_generation(infile, outfile)
      next_gen = 
        evolvers.inject(read_generation(infile)) do |prev, evolver|
          evolver.evolve(Generation.wrap(prev)).unwrap
        end
      write_generation(outfile, next_gen)
      outfile
    end

    def generation(number)
      outfile = locate_generation(number)
      if number == 0
        first_generation(outfile)
      else
        infile = locate_generation(number - 1)
        next_generation(infile, outfile)
      end
    end

    private

    def locate_generation(number)
      config.generation_locator.call(number)
    end
  end
end
