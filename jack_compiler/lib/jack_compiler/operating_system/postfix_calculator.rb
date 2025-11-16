# frozen_string_literal: true

module JackCompiler
  module OperatingSystem
    class PostfixCalculator
      def initialize(expression)
        @expression = expression
      end

      def emit_vm_code
        if expression.include? '+'
          <<~VM_CODE
            push #{x}
            push #{y}

            add
          VM_CODE
        elsif expression.include? '-'
          <<~VM_CODE
            push #{x}
            push #{y}

            // Negate the second number
            neg
            add
          VM_CODE
        elsif expression.include? '&'
          <<~VM_CODE
            push #{x}
            push #{y}

            and
          VM_CODE
        elsif expression.include? '|'
          <<~VM_CODE
            push #{x}
            push #{y}

            or
          VM_CODE
        end
      end
    end
  end
end
