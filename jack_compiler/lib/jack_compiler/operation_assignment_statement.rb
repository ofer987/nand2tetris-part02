# frozen_string_literal: true

module JackCompiler
  class OperationAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::OPERATION_EXPRESSION_REGEX

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(EXPRESSION_STATEMENT)
      parent_node << result_node
      # binding.pry

      term_node = document.create_element(TERM_STATEMENT)
      result_node << term_node

      next_statements(term_node, result[3], next_expression_classes)

      # binding.pry
      lines.sub(REGEX, '')
    end

    def next_expression_classes
      [
        StringAssignmentStatement,
        NullAssignmentStatement,
        IntegerAssignmentStatement,
        VariableAssignmentStatement,
        ArrayAssignmentStatement,
        AssignmentExpressionStatement
      ]
    end
  end
end
