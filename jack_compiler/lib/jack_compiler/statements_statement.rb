# frozen_string_literal: true

module JackCompiler
  class StatementsStatement < Statement
    REGEX = RegularExpressions::STATEMENTS_REGEX

    def create_elements(parent_node, lines)
      result_node = document.create_element(STATEMENTS_STATEMENT)

      parent_node << result_node

      next_lines = lines

      next_statements(result_node, next_lines, statement_classes)
    end

    protected

    def statement_classes
      [IfStatement, LetStatement, DoStatement, ReturnStatement, EmptyReturnStatement]
    end
  end
end
