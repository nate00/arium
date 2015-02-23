module Arium
  module EvolverUtils
    def evolve(array)
      evolve_generation(Generation.wrap(array)).unwrap
    end
  end
end
