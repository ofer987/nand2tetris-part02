# frozen_string_literal: true

module JackCompiler
  # rubocop:disable Metrics/ClassLength
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
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def calculate(memory: {})
      values_stack = []
      operator = nil

      stack.map(&:strip).each do |item|
        if item.match? Utils::Infix::BOOLEAN_CONSTANT_REGEX
          case item.match(Utils::Infix::BOOLEAN_CONSTANT_REGEX)[1]
          when 'true'
            values_stack << 1
          when 'false'
            values_stack << 0
          end
        elsif item.match? Utils::Infix::NUMERICAL_REGEX
          values_stack << item.to_i
        elsif item.match? Utils::Infix::OPERAND_REGEX
          variable_name = item

          raise "Variable '#{variable_name}' has not been declared" unless memory.key? variable_name

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
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def emit_vm_code(memory: {})
      values_stack = []
      operator = nil
      result = []

      # rubocop:disable Metrics/BlockLength
      stack.map(&:strip).each do |item|
        if item.match? Utils::Infix::BOOLEAN_CONSTANT_REGEX
          case item.match(Utils::Infix::BOOLEAN_CONSTANT_REGEX)[1]
          when 'true'
            values_stack << 1
            result << 'push constant 1'
          when 'false'
            values_stack << 0
            result << 'push constant 0'
          end
        elsif item.match? Utils::Infix::NUMERICAL_REGEX
          values_stack << 1
          result << "push constant #{item.to_i}"
        elsif item.match? Utils::Infix::ARRAY_OPERAND_REGEX
          matches = item.match(Utils::Infix::ARRAY_OPERAND_REGEX)
          array_name = matches[2]
          array_index = matches[3]
          values_stack << 1

          variable = memory[array_name]

          result << "push constant #{array_index}"
          result << "push #{variable.kind} #{variable.index}"
          result << 'add'

          result << 'pop pointer 1'
          result << 'push that 0'
        elsif item.match? Utils::Infix::OPERAND_REGEX
          variable_name = item

          raise "Variable '#{variable_name}' has not been declared" unless memory.key? variable_name

          variable = memory[variable_name]

          values_stack << 1
          result << "push #{variable.kind} #{variable.index}"
        elsif item.match? Utils::Infix::OPERATORS_LIST_REGEX
          raise 'Stack is invalid because it contains two consecutive operators' unless operator.blank?

          operator = item

          raise 'Stack contains less than two (2) values' if values_stack.size < 2

          values_stack.pop
          values_stack.pop

          values_stack << 1
          vm_code_operators(operator).each do |vm_code|
            result << vm_code
          end

          # Reset the operator
          operator = nil
        end
      end
      # rubocop:enable Metrics/BlockLength

      if values_stack.size != 1
        raise "Postfix expression #{expression} is invalid: result has #{values_stack.size} values instead of one (1)"
      end

      result
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    private

    def evaluate(first_value, second_value, operator)
      case operator
      when '+'
        first_value + second_value
      when '-'
        first_value - second_value
      when '~'
        first_value - second_value
      when '*'
        first_value * second_value
      when '/'
        first_value / second_value
      when '&'
        first_value & second_value
      when '|'
        first_value | second_value
      else
        raise "operator '#{operator}' is invalid"
      end
    end

    def vm_code_operators(operator)
      case operator
      when '+'
        ['add']
      when '-'
        %w[neg add]
      when '~'
        %w[neg add]
      when '*'
        ['call Math.multiply 2']
      when '/'
        ['call Math.divide 2']
      when '&'
        ['and']
      when '|'
        ['or']
      else
        raise "operator '#{operator}' is invalid"
      end
    end

    def stack
      @stack ||= expression.split(' ')
    end

    attr_reader :infix_expression
  end
  # rubocop:enable Metrics/ClassLength
end
