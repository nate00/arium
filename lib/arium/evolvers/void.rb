module Arium
  module Evolvers
    class Void
      def evolve(previous_gen)
        previous_gen.transform do |gen|
          advance_void(gen)
        end.transform do |gen|
          advance_antivoid(gen)
        end.transform do |gen|
          fill_old_antivoid(gen, previous_gen)
        end.maybe_transform(0.1) do |gen|
          create_void(gen)
        end
      end

      def fill_old_antivoid(generation, previous_generation)
        old_antivoid = previous_generation.select(&:occupant_is_antivoid?)

        generation.transform_cells(old_antivoid) do |cell|
          Occ.plain
        end
      end

      def advance_antivoid(generation)
        void_neighboring_antivoid = generation.
          select(&:occupant_is_void?).
          select { |cell| cell.neighbors.any?(&:occupant_is_antivoid?) }

        generation.transform_cells(void_neighboring_antivoid) do |cell|
          Occ.antivoid
        end
      end

      def advance_void(generation)
        nonvoid_neighboring_void = generation.
          reject { |cell| [Occ.void, Occ.antivoid].include?(cell.occupant) }.
          select { |cell| cell.neighbors.any?(&:occupant_is_void?) }

        generation.transform_cells(nonvoid_neighboring_void) do |cell|
          Occ.void
        end
      end

      def create_void(generation)
        epicenter = generation.cells.sample

        generation.transform_cells([epicenter]) do |cell|
          Occ.antivoid
        end.transform_cells(epicenter.euclidean_neighbors(distance: 3)) do |cell|
          Occ.void
        end
      end
    end
  end
end
