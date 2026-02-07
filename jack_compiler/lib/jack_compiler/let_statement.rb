# frozen_string_literal: true

module JackCompiler
  class LetStatement < Statement
    REGEX = RegularExpressions::LET_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(LET_STATEMENT)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      parent_node << result_node

      value_node = document.create_element(IDENTIFIER, result[2])
      result_node << value_node

      symbol_node = document.create_element(SYMBOL, result[3])
      result_node << symbol_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      result_node << expression_node

      next_statements(expression_node, result[4], next_expression_classes)

      symbol_node = document.create_element(SYMBOL, result[5])
      result_node << symbol_node

      lines.sub(REGEX, '')
    end

    private

    def array_classes
      [ArrrayExpressionStatement]
    end

    def next_expression_classes
      [
        BinaryAssignmentStatement01,
        BinaryAssignmentStatement02,
        BinaryAssignmentStatement03,
        BinaryAssignmentStatement04,
        UnaryAssignmentStatement,
        AssignmentExpressionStatement,
        ArrayAssignmentStatement,
        StringAssignmentStatement,
        NullAssignmentStatement,
        IntegerAssignmentStatement,
        VariableAssignmentStatement
      ]
    end
  end
end
