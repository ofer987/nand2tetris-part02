# frozen_string_literal: true

module JackCompiler
  class PostfixCalculator
    def initialize(infix_expression: '', expression: '')
      @infix_expression = infix_expression unless infix_expression.blank?
      @expression = expression unless expression.blank?

      raise 'Should provide either infix_expression or expression' if infix_expression.blank? && expression.blank?
    end

    def expression
      return @expression if defined? @expression

      @expression = Utils::Infix.to_postfix(infix_expression)
    end

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def calculate(memory: {})
      values_stack = []
      operator = nil

      stack.map(&:strip).each do |item|
        if item.match? Utils::Infix::NUMERICAL_REGEX
          values_stack << item.to_i
        elsif item.match? Utils::Infix::OPERAND_REGEX
          variable_name = item

          raise "Variable '#{variable_name} has not been declared" unless memory.key? variable_name

          variable = memory[variable_name]

          values_stack << variable.value
        elsif item.match? Utils::Infix::OPERATORS_LIST_REGEX
          raise 'Stack is invalid because it contains two consecutive operators' unless operator.blank?

          operator = item

          raise 'Stack contains less than two (2) values' if values_stack.size < 2

          second_value = values_stack.pop
          first_value = values_stack.pop

          values_stack << evaluate(first_value, second_value, operator)

          # Reset the operator
          operator = nil
        end
      end

      if values_stack.size != 1
        raise "Postfix expression #{expression} is invalid: result has #{values_stack.size} values instead of one (1)"
      end

      values_stack.first
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    private

    def evaluate(first_value, second_value, operator)
      case operator
      when '+'
        first_value + second_value
      when '-'
        first_value - second_value
      when '*'
        first_value * second_value
      when '/'
        first_value / second_value
      else
        raise "operator '#{operator}' is invalid"
      end
    end

    def stack
      @stack ||= expression.split(' ')
    end

    attr_reader :infix_expression
  end
end
