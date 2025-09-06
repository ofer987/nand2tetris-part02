# frozen_string_literal: true

module JackCompiler
  class ClassStatement < Statement
    REGEX = RegularExpressions::CLASS

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(CLASS)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, CLASS)
      result_node << keyword_node

      class_name_node = document.create_element(IDENTIFIER, result[1])
      result_node << class_name_node

      symbol_node = document.create_element(SYMBOL, OPEN_BRACE)
      result_node << symbol_node

      next_lines = lines.sub(REGEX, '')
      next_lines = next_statements(result_node, next_lines, next_classes)

      next_statement(result_node, next_lines, end_classes)
    end

    private

    def next_classes
      [ClassVariableStatement, ClassSubroutineStatement]
    end

    def end_classes
      [CloseBraceStatement]
    end
  end
end
