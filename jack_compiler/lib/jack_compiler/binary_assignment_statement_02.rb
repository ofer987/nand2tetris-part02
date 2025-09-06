# frozen_string_literal: true

module JackCompiler
  class BinaryAssignmentStatement02 < ExpressionStatement
    REGEX = RegularExpressions::BINARY_OPERATION_EXPRESSION_REGEX_02

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      # binding.pry

      # First operand
      # TODO
      # What type of operand?
      # And second, check if this is a unary operator
      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      next_statements(term_node, result[1], assignment_expression_classes)
      # value_node = document.create_element(VARIABLE_CONSTANT, result[1])
      # term_node << value_node

      # operator
      symbol_node = document.create_element(SYMBOL, result[2])
      parent_node << symbol_node

      # Second operand
      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      next_statements(term_node, result[3], assignment_expression_classes)
      # parent_node << term_node

      # value_node = document.create_element(VARIABLE_CONSTANT, result[2])
      # term_node << value_node

      # binding.pry
      lines.sub(REGEX, '')
    end

    private

    def assignment_expression_classes
      [
        UnaryAssignmentStatement,
        ArrayAssignmentStatement,
        StringAssignmentStatement,
        IntegerAssignmentStatement,
        NullAssignmentStatement,
        VariableAssignmentStatement
      ]
    end
  end
end
