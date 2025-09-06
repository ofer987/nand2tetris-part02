# frozen_string_literal: true

module JackCompiler
  class LetStatement < Statement
    REGEX = RegularExpressions::LET_STATEMENT
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(LET_STATEMENT)
      # binding.pry

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      parent_node << result_node

      if result[2].match? ArrrayExpressionStatement::REGEX
        next_statements(result_node, result[2], array_classes)
      else
        value_node = document.create_element(IDENTIFIER, result[2])
        result_node << value_node
      end

      symbol_node = document.create_element(SYMBOL, result[3])
      result_node << symbol_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      result_node << expression_node

      # binding.pry
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
        StringAssignmentStatement,
        NullAssignmentStatement,
        IntegerAssignmentStatement,
        ArrayAssignmentStatement,
        VariableAssignmentStatement
      ]
    end
  end
end
