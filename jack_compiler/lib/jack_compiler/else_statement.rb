# frozen_string_literal: true

module JackCompiler
  class ElseStatement < Statement
    REGEX = RegularExpressions::ELSE_STATEMENT_REGEX

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      keyword_node = document.create_element(KEYWORD, result[1])
      parent_node << keyword_node

      symbol_node = document.create_element(SYMBOL, result[2])
      parent_node << symbol_node

      next_lines = lines.sub(REGEX, '')
      next_lines = next_statements(parent_node, next_lines, next_classes)

      next_statements(parent_node, next_lines, end_classes)
    end

    protected

    def next_classes
      [VariableStatement, StatementsStatement]
    end

    def end_classes
      [CloseBraceStatement]
    end
  end
end
