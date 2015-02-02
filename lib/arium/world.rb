require 'JSON'

module Arium
  class World
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

    private

    def read_generation(filename)
      JSON.parse(File.open(filename).read, symbolize_names: true)
    end

    def write_generation(filename, generation)
      File.open(filename, 'w') do |f|
        f.write(JSON.generate(generation))
      end
    end
  end
end
