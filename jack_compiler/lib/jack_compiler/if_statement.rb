# frozen_string_literal: true

module JackCompiler
  class IfStatement < Statement
    REGEX = RegularExpressions::IF_STATEMENT_REGEX
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      # return ''
      #
      # binding.pry
      result = lines.match(REGEX)

      result_node = document.create_element(IF_STATEMENT)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      symbol_node = document.create_element(SYMBOL, result[2])
      result_node << symbol_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      parent_node << expression_node

      term_node = document.create_element(TERM_STATEMENT)
      expression_node << term_node

      keyword_node = document.create_element(KEYWORD, result[3])
      term_node << keyword_node

      symbol_node = document.create_element(SYMBOL, result[4])
      result_node << symbol_node

      symbol_node = document.create_element(SYMBOL, result[5])
      result_node << symbol_node

      binding.pry
      next_lines = lines.sub(REGEX, '')
      next_lines = next_statements(result_node, next_lines, next_classes)

      next_lines = next_statements(parent_node, next_lines, end_classes)
      next_statements(parent_node, next_lines, else_classes)
    end

    protected

    def next_classes
      [VariableStatement, StatementsStatement]
    end

    def end_classes
      [CloseBraceStatement]
    end

    def else_classes
      [ElseStatement]
    end
  end
end
