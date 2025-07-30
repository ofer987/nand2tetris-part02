# frozen_string_literal: true

module JackCompiler
  class ClassSubroutineStatement < Statement
    REGEX = RegularExpressions::CLASS_VAR_STATEMENT
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      variable_node = document.create_element(SUBROUTINE_DESCRIPTION)
      # binding.pry

      parent_node << variable_node

      keyword_node = document.create_element(KEYWORD, result[1])
      variable_node << keyword_node

      keyword_node = document.create_element(KEYWORD, result[2])
      variable_node << keyword_node

      identifier_node = document.create_element(IDENTIFIER, result[3])
      variable_node << identifier_node

      symbol_node = document.create_element(SYMBOL, OPEN_PARENTHESIS)
      variable_node << symbol_node

      # TODO: implement **parameterList**

      symbol_node = document.create_element(SYMBOL, CLOSE_PARENTHESIS)
      variable_node << symbol_node

      # TODO: implement **subroutineBody**

      # binding.pry
      next_lines = lines.sub(REGEX, '')
      next_statements(variable_node, next_lines)
    end
  end
end
