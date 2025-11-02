# frozen_string_literal: true

module JackCompiler
  class IntegerAssignmentStatement < ExpressionStatement
    REGEX = RegularExpressions::INTEGER_CONSTANT_ASSIGNMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      evaluation_node = document.create_element(EVALUATION_STATEMENT, result[1].strip)
      evaluation_type_node = document.create_element(EVALUATION_TYPE_STATEMENT, INTEGER_CONSTANT)

      parent_node << evaluation_node
      parent_node << evaluation_type_node

      term_node = document.create_element(TERM_STATEMENT)
      parent_node << term_node

      value_node = document.create_element(INTEGER_CONSTANT, result[1])
      term_node << value_node

      lines.sub(REGEX, '')
    end
  end
end
