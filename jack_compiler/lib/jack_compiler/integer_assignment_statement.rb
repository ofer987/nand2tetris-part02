# frozen_string_literal: true

module JackCompiler
  class IntegerAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::INTEGER_CONSTANT_ASSIGNMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(EXPRESSION_STATEMENT)
      parent_node << result_node
      # binding.pry

      term_node = document.create_element(TERM_STATEMENT)
      result_node << term_node

      value_node = document.create_element(INTEGER_CONSTANT, result[1])
      term_node << value_node

      # binding.pry
      lines.sub(REGEX, '')
    end
  end
end
