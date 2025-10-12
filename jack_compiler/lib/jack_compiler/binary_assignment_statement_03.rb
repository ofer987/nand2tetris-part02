# frozen_string_literal: true

module JackCompiler
  class BinaryAssignmentStatement03 < ExpressionStatement
    REGEX = RegularExpressions::BINARY_OPERATION_EXPRESSION_REGEX_03

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      evaluation_node = document.create_element(EVALUATION_STATEMENT, result[1])
      parent_node << evaluation_node

      # First operand
      next_statements(parent_node, result[2], assignment_expression_classes)

      # operator
      symbol_node = document.create_element(SYMBOL, result[2])
      parent_node << symbol_node

      # Second operand
      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      next_statements(term_node, result[4], unary_assignment_expression_classes)

      lines.sub(REGEX, '')
    end

    private

    def assignment_expression_classes
      [
        ArrayAssignmentStatement,
        StringAssignmentStatement,
        IntegerAssignmentStatement,
        NullAssignmentStatement,
        VariableAssignmentStatement
      ]
    end

    def unary_assignment_expression_classes
      [
        UnaryAssignmentStatement
      ]
    end
  end
end
