# frozen_string_literal: true

module JackCompiler
  class CloseBraceStatement < Statement
    REGEX = RegularExpressions::CLOSE_BRACE
    EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines[0].match(REGEX)
      variable_node = document.create_element('class')

      document << variable_node

      keyword_node = document.create_element('keyword', 'class')
      variable_node << keyword_node

      identifier_node = document.create_element('identifier', result[1])
      variable_node << identifier_node

      next_statements(lines[1..])
    end

    def next_statements(next_lines)
      return if next_lines.empty?

      first_line = next_lines[0]

      first_line
    end

    protected

    def next_classes
      [BeginClassStatement]
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
