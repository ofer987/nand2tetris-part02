# frozen_string_literal: true

module JackCompiler
  class OpenBraceStatement < Statement
    REGEX = RegularExpressions::OPEN_BRACE

    def create_elements(parent_node, lines)
      # binding.pry unless lines.match?(REGEX)

      # binding.pry
      result = lines.match(REGEX)
      symbol_node = document.create_element(SYMBOL, OPEN_BRACE)

      parent_node << symbol_node

      binding.pry
      next_lines = lines.sub(REGEX, '')
      next_statements(next_lines)
    end

    def next_statements(next_lines)
      return if next_lines.empty?

      first_line
    end

    protected

    def next_classes
      # [BeginClassStatement]
      []
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
