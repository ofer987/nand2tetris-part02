# frozen_string_literal: true

module JackCompiler
  class WhileStatement < Statement
    REGEX = RegularExpressions::WHILE_STATEMENT_REGEX
    NODE_NAME = WHILE_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      result_node = document.create_element(WHILE_STATEMENT)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      symbol_node = document.create_element(SYMBOL, result[2])
      result_node << symbol_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      result_node << expression_node

      next_statements(expression_node, result[3], next_equality_statements)

      symbol_node = document.create_element(SYMBOL, result[4])
      result_node << symbol_node

      symbol_node = document.create_element(SYMBOL, result[5])
      result_node << symbol_node

      next_lines = lines.sub(REGEX, '')

      next_lines = next_statements(result_node, next_lines, next_classes)

      next_statements(result_node, next_lines, end_classes)
    end

    protected

    # TODO: add null equality
    # TODO: add reference equality
    def next_equality_statements
      [
        BooleanAssignmentStatement,
        LessThanExpressionStatement
      ]
    end

    def next_classes
      [VariableStatement, StatementsStatement]
    end

    def end_classes
      [CloseBraceStatement]
    end
  end
end
