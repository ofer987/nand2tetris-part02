# frozen_string_literal: true

module JackCompiler
  class BooleanExpression
    attr_reader :value

    def initialize(value)
      @value = value

      if self.value.match? RegularExpressions::LESS_THAN_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
        self.operator = 'lt'
      elsif self.value.match? RegularExpressions::LESS_THAN_OR_EQUAL_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
      elsif self.value.match? RegularExpressions::GREATER_THAN_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
      elsif self.value.match? RegularExpressions::GREATER_THAN_OR_EQUAL_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
      else
        raise "Error: #{value} is not a correct boolean expression"
      end
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

    private

    def init_boolean_expression(value, regex)
      matches = value.match(regex)

      self.left_operand = matches[1]
      self.operator = matches[2]
      self.right_operand = matches[3]
    end

    attr_accessor :operator, :left_operand, :right_operand
    attr_writer :value
  end
end
