# frozen_string_literal: true

module JackCompiler
  class CloseBraceStatement < Statement
    REGEX = RegularExpressions::CLOSE_BRACE

    def create_elements(parent_node, lines)
      result_node = document.create_element(CLOSE_BRACE)
      parent_node << result_node

      lines.sub(REGEX, '')
    end
  end
end
