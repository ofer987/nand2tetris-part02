# frozen_string_literal: true

module JackCompiler
  class NewClassAssignmentStatement < Statement
    REGEX = RegularExpressions::CLASS_NEW_EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      identifier_node = document.create_element(IDENTIFIER, ARRAY_CLASS)
      parent_node << identifier_node

      evaluation_node = document.create_element(EVALUATION_STATEMENT, result[1])
      evaluation_node_type = document.create_element(EVALUATION_TYPE_STATEMENT, NEW_CLASS_TYPE)

      expression_list_node = document.create_element(EXPRESSION_LIST)
      next_statements(expression_list_node, result[2], next_argument_classes)

      term_node = document.create_element(TERM_STATEMENT)
      term_node << expression_list_node
      parent_node << term_node

      parent_node << evaluation_node
      parent_node << evaluation_node_type

      lines.sub(REGEX, '')
    end

    private

    def next_argument_classes
      [ArgumentStatement]
    end
  end
end
