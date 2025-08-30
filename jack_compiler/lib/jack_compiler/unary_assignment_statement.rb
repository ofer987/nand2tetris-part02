# frozen_string_literal: true

module JackCompiler
  class UnaryAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::UNARY_OPERATION_EXPRESSION_REGEX

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      symbol_node = document.create_element(SYMBOL, result[1])
      parent_node << symbol_node

      next_statements(parent_node, result[2], assignment_expression_classes)

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
  end
end
