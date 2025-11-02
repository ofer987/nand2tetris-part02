# frozen_string_literal: true

module JackCompiler
  class UnaryAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::UNARY_OPERATION_EXPRESSION_REGEX

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      symbol_node = document.create_element(SYMBOL, result[1])
      parent_node << symbol_node

      evaluation_node = document.create_element(EVALUATION_STATEMENT, result[1])
      evaluation_type_node = document.create_element(EVALUATION_TYPE_STATEMENT, INFIX_EXPRESSION)

      parent_node << evaluation_node
      parent_node << evaluation_type_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      parent_node << expression_node

      term_node = document.create_element(TERM_STATEMENT)
      expression_node << term_node

      symbol_node = document.create_element(SYMBOL, result[2])
      term_node << symbol_node

      next_statements(term_node, result[3], assignment_expression_classes)

      symbol_node = document.create_element(SYMBOL, result[4])
      parent_node << symbol_node

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
