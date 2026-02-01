# frozen_string_literal: true

module JackCompiler
  class BooleanExpression
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def calculate(objects)
      calculator = PostfixCalculator.new(expression: value)

      variable.value = calculator.calculate(memory: objects)
    end

    def emit_vm_code(objects)
      calculator = PostfixCalculator.new(expression: value)

      calculator.emit_vm_code(memory: objects)
        .join("\n")
    end
  end
end
