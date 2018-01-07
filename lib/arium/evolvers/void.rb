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

      def fill_old_antivoid(gen, previous_gen)
        old_antivoid = previous_gen.select(&:occupant_is_antivoid?)

        gen.transform_cells(old_antivoid) do |cell|
          Occ.plain
        end
      end

      def advance_antivoid(gen)
        void_neighboring_antivoid = gen.
          select(&:occupant_is_void?).
          select { |cell| gen.neighbors(cell).any?(&:occupant_is_antivoid?) }

        gen.transform_cells(void_neighboring_antivoid) do |cell|
          Occ.antivoid
        end
      end

      def advance_void(gen)
        nonvoid_neighboring_void = gen.
          reject { |cell| [Occ.void, Occ.antivoid].include?(cell.occupant) }.
          select { |cell| gen.neighbors(cell).any?(&:occupant_is_void?) }

        gen.transform_cells(nonvoid_neighboring_void) do |cell|
          Occ.void
        end
      end

      def create_void(gen)
        epicenter = gen.cells.sample

        gen.transform_cells([epicenter]) do |cell|
          Occ.antivoid
        end.transform_cells(gen.euclidean_neighbors(epicenter, distance: 3)) do |cell|
          Occ.void
        end
      end
    end
  end
end
