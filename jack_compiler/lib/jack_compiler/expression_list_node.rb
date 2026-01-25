# frozen_string_literal: true

module JackCompiler
  class ExpressionListNode < Node
    # TODO: fix me
    REGEX = //
    NODE_NAME = Statement::EXPRESSION_LIST

    CONSTANT_TYPES = [
      Statement::INTEGER_CONSTANT,
      Statement::NULL_CONSTANT,
      Statement::BOOLEAN_CONSTANT
    ].freeze

    attr_reader :parameters

    def size
      return @size if defined? @size

      values = find_child_nodes_with_css_selector(Statement::EVALUATION_STATEMENT)
        .map(&:text)
      value_types = find_child_nodes_with_css_selector(Statement::EVALUATION_TYPE_STATEMENT)
        .map(&:text)

      unless values.size == value_types.size
        raise "Parameter list has #{values.size} values, but only #{value_types.size} types"
      end

      @size = values.size
    end

    def emit_vm_code(memory_scope)
      init_parameters(memory_scope)

      parameters
        .map { |item| argument_vm_code(item) }
        .join("\n")
    end

    private

    def argument_vm_code(argument)
      if argument[:is_constant]
        "push constant #{argument[:value]}"
      else
        variable = argument[:value]
        "push #{variable.kind} #{variable.index}"
      end
    end

    def init_parameters(memory_scope)
      @parameters = []

      values = find_child_nodes_with_css_selector(Statement::EVALUATION_STATEMENT)
        .map(&:text)
      value_types = find_child_nodes_with_css_selector(Statement::EVALUATION_TYPE_STATEMENT)
        .map(&:text)

      unless values.size == value_types.size
        raise "Parameter list has #{values.size} values, but only #{value_types.size} types"
      end

      values.each_with_index do |value, index|
        value_type = value_types[index]

        is_constant = CONSTANT_TYPES.include? value_type
        parameter = {
          type: value_type,
          is_constant: is_constant,
          value: value
        }
        parameter[:value] = memory_scope[value] unless is_constant

        @parameters << parameter
      end
    end
  end
end
