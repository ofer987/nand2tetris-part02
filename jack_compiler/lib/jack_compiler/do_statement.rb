# frozen_string_literal: true

module JackCompiler
  class DoStatement < Statement
    REGEX = RegularExpressions::DO_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(DO_STATEMENT)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      next_statements(result_node, result[2], next_expression_classes)

      symbol_node = document.create_element(SYMBOL, result[-1])
      result_node << symbol_node

      lines.sub(REGEX, '')
    end

    private

    def next_expression_classes
      [ExecutionExpressionStatement]
    end
  end
end
