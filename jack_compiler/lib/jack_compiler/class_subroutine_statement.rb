# frozen_string_literal: true

module JackCompiler
  class ClassSubroutineStatement < Statement
    REGEX = RegularExpressions::FUNCTION
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      binding.pry
      result = lines.match(REGEX)
      result_node = document.create_element(SUBROUTINE_DESCRIPTION)
      # binding.pry

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      keyword_node = document.create_element(KEYWORD, result[2])
      result_node << keyword_node

      identifier_node = document.create_element(IDENTIFIER, result[3])
      result_node << identifier_node

      symbol_node = document.create_element(SYMBOL, OPEN_PARENTHESIS)
      result_node << symbol_node

      # TODO: implement **parameterList**
      # unless result[4].to_s.blank?

      symbol_node = document.create_element(SYMBOL, CLOSE_PARENTHESIS)
      result_node << symbol_node

      # TODO: implement **subroutineBody**

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
