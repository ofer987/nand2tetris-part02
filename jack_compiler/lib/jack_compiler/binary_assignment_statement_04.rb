# frozen_string_literal: true

module JackCompiler
  class BinaryAssignmentStatement04 < ExpressionStatement
    REGEX = RegularExpressions::BINARY_OPERATION_EXPRESSION_REGEX_04

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      # First operand
      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      next_statements(term_node, result[1], assignment_expression_classes)

      # operator
      symbol_node = document.create_element(SYMBOL, result[2])
      parent_node << symbol_node

      # Second operand
      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      next_statements(term_node, result[3], assignment_expression_classes)

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
