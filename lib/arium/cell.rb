module Arium
  class Cell
    attr_accessor :occupant, :altitude
    attr_accessor :row, :col

    def initialize(occupant, altitude, row, col)
      self.occupant = occupant
      self.altitude = altitude
      @row = row
      @col = col
    end

    def inspect
      "<Cell:#{occupant.inspect}>"
    end

    def point
      Point.new(row, col)
    end
    alias to_point point

    def occupant=(occupant)
      unless occupant.is_a?(Occupant)
        raise "Argument to occupant= must be an Occupant, instead got #{occupant.inspect}"
      end
      @occupant = occupant
    end

    def altitude=(altitude)
      unless (0..100).include?(altitude)
        raise "Argument to altitude= must be a number between 0 and 100, instead got #{occupant.inspect}"
      end
      @altitude = altitude
    end

    def method_missing(method_name, *args, &block)
      if (m = /occupant_is_(.+)\?/.match(method_name)) && Occupant::VALID_STRINGS.include?(m[1])
        occupant.public_send(:"#{m[1]}?")
      else
        super
      end
    end
  end
end
