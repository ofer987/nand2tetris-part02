# frozen_string_literal: true

module JackCompiler
  class FunctionStatement < Statement
    REGEX = RegularExpressions::FUNCTION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      function_node = document.create_element(SUBROUTINE_DESCRIPTION)

      parent_node << function_node

      keyword_node = document.create_element(KEYWORD, result[1])
      function_node << keyword_node

      keyword_node = document.create_element(KEYWORD, result[2])
      function_node << keyword_node

      symbol_node = document.create_element(KEYWORD, OPEN_PARENTHESIS)
      function_node << symbol_node

      parameter_list_node = document.create_element(KEYWORD, PARAMETER_LIST)
      function_node << parameter_list_node

      symbol_node = document.create_element(KEYWORD, CLOSE_PARENTHESIS)
      function_node << symbol_node

      next_lines = lines.sub(result[0], '')
      next_statements(result_node, next_lines)
    end

    def next_statements(parent_node, next_lines)
      # binding.pry
      return if next_lines.empty?

      next_klass = next_classes.first { |klass| klass::REGEX.match? next_lines }

      next_klass
        .new(document)
        .create_elements(parent_node, next_lines)
    end

    protected

    def next_classes
      [OpenBraceStatement]
      # [FieldStatement, ConstructorStatement, FunctionStatement, MethodStatement]
    end

    private

    def inner_create_elements(parent_node, regex_result)
      term_node = document.create_element('term')
      parent_node << term_node

      identifier_node = document.create_element('identifier', regex_result[1])
      term_node << identifier_node

      symbol_node = document.create_element('symbol', regex_result[2])
      parent_node << symbol_node

      term_node = document.create_element('term')
      parent_node << term_node

      integer_constant = document.create_element('integerConstant', regex_result[3])
      term_node << integer_constant
    end
  end
end
