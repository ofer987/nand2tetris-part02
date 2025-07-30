# frozen_string_literal: true

module JackCompiler
  class VariableStatement < Statement
    REGEX = RegularExpressions::VAR_STATEMENT
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(VAR_DESCRIPTION)
      # binding.pry

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      identifier_node = document.create_element(IDENTIFIER, result[2])
      result_node << identifier_node

      identifier_node = document.create_element(IDENTIFIER, result[3])
      result_node << identifier_node

      symbol_node = document.create_element(SYMBOL, SEMI_COLON)
      result_node << symbol_node

      # binding.pry
      next_lines = lines.sub(REGEX, '')
      next_statements(result_node, next_lines)
    end

    protected

    def next_classes
      [SubroutineBodyStatement]
    end
  end
end
