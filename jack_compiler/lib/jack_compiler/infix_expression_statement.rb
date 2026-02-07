# frozen_string_literal: true

module JackCompiler
  class InfixExpressionStatement < ExpressionStatement
    REGEX = RegularExpressions::INFIX_EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      evaluation_node = document.create_element(EVALUATION_STATEMENT, result[1])
      evaluation_type_node = document.create_element(EVALUATION_TYPE_STATEMENT, INFIX_EXPRESSION)

      parent_node << evaluation_node
      parent_node << evaluation_type_node

      lines.sub(REGEX, '')
    end
  end
end
