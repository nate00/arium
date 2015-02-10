module Arium
  module Creators
    class Example
      attr_accessor :rows, :columns
      def initialize
        yield self if block_given?
      end

      def create
        columns.times.map { [:plain] * rows }
      end

      def rows
        @rows ||= 100
      end

      def columns
        @columns ||= 100
      end
    end
  end
end
