# frozen_string_literal: true

module JackCompiler
  class EmptyReturnStatement < Statement
    REGEX = RegularExpressions::EMPTY_RETURN_STATEMENT
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(RETURN_STATEMENT)
      # binding.pry

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      symbol_node = document.create_element(SYMBOL, result[2])
      result_node << symbol_node

      lines.sub(REGEX, '')
    end
  end
end
