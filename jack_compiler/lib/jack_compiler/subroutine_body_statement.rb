# frozen_string_literal: true

module JackCompiler
  class SubroutineBodyStatement < Statement
    REGEX = RegularExpressions::OPEN_BRACE

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(SUBROUTINE_BODY)

      parent_node << result_node

      symbol_node = document.create_element(SYMBOL, result[1])
      result_node << symbol_node

      next_lines = lines.sub(REGEX, '')
      next_lines = next_statements(result_node, next_lines, variable_classes)

      statements_node = document.create_element(STATEMENTS_STATEMENT)
      result_node << statements_node

      next_lines = next_statements(statements_node, next_lines, statement_classes)

      next_statement(result_node, next_lines, end_classes)
    end

    protected

    def variable_classes
      [VariableStatement]
    end

    def statement_classes
      [IfStatement, LetStatement, DoStatement, ReturnStatement, EmptyReturnStatement]
    end

    def end_classes
      [CloseBraceStatement]
    end
  end
end
