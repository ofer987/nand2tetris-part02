# frozen_string_literal: true

module JackCompiler
  class ArrayAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::ARRAY_EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      identifier_node = document.create_element(IDENTIFIER, result[1])
      term_node << identifier_node

      symbol_node = document.create_element(SYMBOL, result[2])
      term_node << symbol_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      term_node << expression_node

      next_statements(expression_node, result[3], next_expression_classes)

      symbol_node = document.create_element(SYMBOL, result[4])
      term_node << symbol_node

      lines.sub(REGEX, '')
    end

    def next_expression_classes
      [IntegerAssignmentStatement]
    end
  end
end
