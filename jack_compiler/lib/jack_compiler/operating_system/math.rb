# frozen_string_literal: true

module JackCompiler
  module OperatingSystem
    # TODO: Rename to Math
    class Math < self
      # attr_reader :r, :x
      #
      # def initialize(x, y)
      #   @x = x
      #   @y = y
      # end

      def bitwise_and(x, y)
        <<~VM_CODE
          push #{x}
          push #{y}
          and
        VM_CODE
      end

      def bitwise_or(x, y)
        <<~VM_CODE
          push #{x}
          push #{y}
          or
        VM_CODE
      end

      def bit(x, index)
        <<~VM_CODE
          push #{x}
          push #{index}
          and
        VM_CODE
      end

      def add(x, y)
        <<~VM_CODE
          push #{x}
          push #{y}
          add
        VM_CODE
      end

      # def multiply(x, y)
      #   # TODO: Check for positive sign
      #
      #   x = y
      #   <<~VM_CODE
      #
      #   VM_CODE
      # end
    end
  end
end
