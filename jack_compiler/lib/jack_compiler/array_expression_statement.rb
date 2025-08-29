# frozen_string_literal: true

module JackCompiler
  class ArrrayExpressionStatement < Statement
    REGEX = RegularExpressions::ARRAY_EXPRESSION
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      binding.pry
      result = lines.match(REGEX)
      # result_node = document.create_element(LET_STATEMENT)
      # binding.pry

      # parent_node << result_node

      identifier_node = document.create_element(IDENTIFIER, result[1])
      parent_node << identifier_node

      symbol_node = document.create_element(SYMBOL, result[2])
      parent_node << symbol_node

      next_statements(parent_node, result[3], next_expression_classes)

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
