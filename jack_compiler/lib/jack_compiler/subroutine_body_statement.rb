# frozen_string_literal: true

module JackCompiler
  class SubroutineBodyStatement < Statement
    REGEX = RegularExpressions::OPEN_BRACE
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(SUBROUTINE_BODY)
      # binding.pry

      parent_node << result_node

      symbol_node = document.create_element(SYMBOL, result[1])
      result_node << symbol_node
      # binding.pry

      next_lines = lines.sub(REGEX, '')
      next_lines = next_statements(result_node, next_lines, variable_classes)

      # keyword_node = document.create_element(KEYWORD, result[2])
      # result_node << keyword_node
      #
      # identifier_node = document.create_element(IDENTIFIER, result[3])
      # result_node << identifier_node
      #
      # symbol_node = document.create_element(SYMBOL, OPEN_BRACE)
      # result_node << symbol_node

      # TODO: implement **parameterList**
      # unless result[4].to_s.blank?

      statements_node = document.create_element(STATEMENTS)
      result_node << statements_node

      # binding.pry
      next_statements(statements_node, next_lines, statement_classes)
    end

    protected

    def variable_classes
      [VariableStatement]
    end

    def statement_classes
      [IfStatement, LetStatement, DoStatement, ReturnStatement, EmptyReturnStatement]
    end
  end
end
