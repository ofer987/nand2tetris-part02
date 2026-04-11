# frozen_string_literal: true

module JackCompiler
  class DoStatement < Statement
    NODE_NAME = DO_STATEMENT
    REGEX = RegularExpressions::DO_STATEMENT
    NEW_METHOD = 'new'

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      raise "Cannot instantiate new instance of '#{result[3]}' in '#{result[0]}'" if result[5] == NEW_METHOD

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
