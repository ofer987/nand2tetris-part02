# frozen_string_literal: true

module JackCompiler
  class NullAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::NULL_CONSTANT_ASSIGNMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      value_node = document.create_element(NULL_CONSTANT, result[1])
      term_node << value_node

      lines.sub(REGEX, '')
    end
  end
end
