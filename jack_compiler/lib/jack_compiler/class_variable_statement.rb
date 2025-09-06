# frozen_string_literal: true

module JackCompiler
  class ClassVariableStatement < Statement
    REGEX = RegularExpressions::CLASS_VAR_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(CLASS_VAR_DESCRIPTION)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      keyword_node = document.create_element(KEYWORD, result[2])
      result_node << keyword_node

      identifier_node = document.create_element(IDENTIFIER, result[3])
      result_node << identifier_node

      symbol_node = document.create_element(SYMBOL, SEMI_COLON)
      result_node << symbol_node

      lines.sub(REGEX, '')
    end
  end
end
