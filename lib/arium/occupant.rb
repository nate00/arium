# An occupant is a thing that can occupy a cell, such as water or a farm.

module Arium
  class Occupant
    VALID_STRINGS = %w[
      plain
      mountain
      farm
      village
      water
      void
      antivoid
    ]

    def initialize(string)
      raise "Invalid occupant string: #{string}" unless VALID_STRINGS.include?(string)
      @string = string
    end

    VALID_STRINGS.each do |string|
      define_singleton_method(string) do
        new(string)
      end

      define_method(:"#{string}?") do
        self.string == string
      end
    end

    def ==(other)
      return false unless other.is_a?(Occupant)

      other.string == self.string
    end
    alias eql? ==

    def hash
      string.hash
    end

    def serialize
      string
    end

    def inspect
      "Occ:#{string}"
    end

    protected

    attr_reader :string
  end

  Occ = Occupant
end
