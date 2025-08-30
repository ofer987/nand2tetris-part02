# frozen_string_literal: true

module JackCompiler
  # TODO: rename of method assignment statement
  # For executing methods of classes
  class AssignmentExpressionStatement < ExpressionStatement
    REGEX = RegularExpressions::ASSIGNMENT_EXPRESSION_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(EXPRESSION_STATEMENT)
      parent_node << result_node
      # binding.pry

      term_node = document.create_element(TERM_STATEMENT)
      result_node << term_node

      identifier_node = document.create_element(IDENTIFIER, result[1])
      term_node << identifier_node

      symbol_node = document.create_element(SYMBOL, result[2])
      term_node << symbol_node

      identifier_node = document.create_element(IDENTIFIER, result[3])
      term_node << identifier_node

      symbol_node = document.create_element(SYMBOL, result[4])
      term_node << symbol_node

      expression_list_node = document.create_element(EXPRESSION_LIST)
      next_statements(expression_list_node, result[5], next_classes)

      term_node << expression_list_node

      symbol_node = document.create_element(SYMBOL, result[6])
      term_node << symbol_node

      # binding.pry
      lines.sub(REGEX, '')
    end

    private

    def next_classes
      [ArgumentStatement]
    end
  end
end
