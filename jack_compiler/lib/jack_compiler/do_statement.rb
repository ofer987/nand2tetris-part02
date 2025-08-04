# frozen_string_literal: true

module JackCompiler
  class DoStatement < Statement
    REGEX = RegularExpressions::DO_STATEMENT
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(DO_STATEMENT)
      # binding.pry

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      # TODO: Implement the expression

      lines.sub(REGEX, '')
    end
  end
end
