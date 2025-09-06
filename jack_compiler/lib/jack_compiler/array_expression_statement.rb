# frozen_string_literal: true

module JackCompiler
  class ArrrayExpressionStatement < Statement
    REGEX = RegularExpressions::ARRAY_EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      identifier_node = document.create_element(IDENTIFIER, result[1])
      parent_node << identifier_node

      symbol_node = document.create_element(SYMBOL, result[2])
      parent_node << symbol_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      parent_node << expression_node

      next_statements(expression_node, result[3], next_expression_classes)

      symbol_node = document.create_element(SYMBOL, result[4])
      parent_node << symbol_node

      lines.sub(REGEX, '')
    end

    private

    def next_expression_classes
      [IntegerAssignmentStatement]
    end
  end
end
