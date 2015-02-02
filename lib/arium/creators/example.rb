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
        @rows ||= 10
      end

      def columns
        @columns ||= 10
      end
    end
  end
end
