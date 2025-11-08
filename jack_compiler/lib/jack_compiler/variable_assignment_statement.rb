# frozen_string_literal: true

module JackCompiler
  class VariableAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::VARIABLE_ASSIGNMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      evaluation_node = document.create_element(EVALUATION_STATEMENT, result[1])
      parent_node << evaluation_node

      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      value_node = document.create_element(VARIABLE_CONSTANT, result[2])
      term_node << value_node

      lines.sub(REGEX, '')
    end
  end
end
