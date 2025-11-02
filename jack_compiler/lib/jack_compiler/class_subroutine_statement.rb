# frozen_string_literal: true

module JackCompiler
  class ClassSubroutineStatement < Statement
    REGEX = RegularExpressions::FUNCTION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(SUBROUTINE_DESCRIPTION)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      keyword_node = document.create_element(KEYWORD, result[2])
      result_node << keyword_node

      identifier_node = document.create_element(IDENTIFIER, result[3])
      result_node << identifier_node

      symbol_node = document.create_element(SYMBOL, OPEN_PARENTHESIS)
      result_node << symbol_node

      parameter_list_node = document.create_element(PARAMETER_LIST)
      result_node << parameter_list_node

      next_statements(parameter_list_node, result[4], next_parameter_classes)

      symbol_node = document.create_element(SYMBOL, CLOSE_PARENTHESIS)
      result_node << symbol_node

      next_lines = lines.sub(REGEX, '')
      next_statements(result_node, next_lines, next_classes)
    end

    private

    def next_parameter_classes
      [ParametersStatement]
    end

    def next_classes
      [SubroutineBodyStatement]
    end
  end
end
