# frozen_string_literal: true

module JackCompiler
  class ExecutionExpressionStatement < ExpressionStatement
    REGEX = RegularExpressions::EXECUTION_EXPRESSION_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = parent_node

      keyword_node = document.create_element(IDENTIFIER, result[1])
      result_node << keyword_node

      symbol_node = document.create_element(SYMBOL, result[2])
      result_node << symbol_node

      keyword_node = document.create_element(IDENTIFIER, result[3])
      result_node << keyword_node

      symbol_node = document.create_element(SYMBOL, result[4])
      result_node << symbol_node

      expression_list_node = document.create_element(EXPRESSION_LIST)
      result_node << expression_list_node

      next_statements(expression_list_node, result[5], next_argument_classes)

      symbol_node = document.create_element(SYMBOL, result[6])
      result_node << symbol_node

      lines.sub(REGEX, '')
    end

    private

    def next_argument_classes
      [ArgumentStatement]
    end
  end
end
