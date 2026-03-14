# frozen_string_literal: true

module JackCompiler
  class BooleanExpression
    def initialize(value, memory_scope)
      @value = value
      @memory_scope = memory_scope

      if self.value.match? RegularExpressions::LESS_THAN_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
        @operator = 'lt'
      elsif self.value.match? RegularExpressions::LESS_THAN_OR_EQUAL_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
        @operator = 'le'
      elsif self.value.match? RegularExpressions::GREATER_THAN_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
        @operator = 'gt'
      elsif self.value.match? RegularExpressions::GREATER_THAN_OR_EQUAL_REGEX
        init_boolean_expression(self.value, RegularExpressions::LESS_THAN_REGEX)
        @operator = 'ge'
      elsif self.value.match? RegularExpressions::EQUAL_REGEX
        init_boolean_expression(self.value, RegularExpressions::EQUAL_REGEX)
        @operator = 'eq'
      elsif self.value.match? RegularExpressions::NOT_EQUAL_REGEX
        init_boolean_expression(self.value, RegularExpressions::NOT_EQUAL_REGEX)
        @operator = 'ne'
      elsif self.value == 'true'
        self.left_operand = 0
        self.right_operand = 0
        @operator = 'eq'
      elsif self.value == 'false'
        self.left_operand = 0
        self.right_operand = 1
        @operator = 'eq'
      elsif memory_scope.key? self.value
        self.left_operand = self.value
        self.right_operand = 0
        @operator = 'eq'
      else
        raise "Error: #{value} is not a correct boolean expression"
      end
    end

    def emit_vm_code
      <<~VM_CODE
        #{left_operand}
        #{right_operand}
        #{operator}
      VM_CODE
    end

    private

    def init_boolean_expression(value, regex)
      matches = value.match(regex)

      self.left_operand = matches[1]
      self.right_operand = matches[2]
    end

    def left_operand=(value)
      @left_operand = operand(value)
    end

    def right_operand=(value)
      @right_operand = operand(value)
    end

    def operand(value)
      return 'push constant 0' if value == 'true'
      return 'push constant 1' if value == 'false'

      return "push constant #{Integer(value)}" if value.is_a?(String) && value.match?(/^\d+$/)
      return "push constant #{value}" if value.is_a? Integer

      variable = memory_scope[value]
      raise "Error: '#{value}' is neither a literal 'true', 'false' or a variable" if variable.nil?

      variable.read_memory
    end

    attr_reader :memory_scope, :value, :left_operand, :right_operand, :operator
  end
end
