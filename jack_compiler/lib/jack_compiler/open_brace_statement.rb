# frozen_string_literal: true

module JackCompiler
  class OpenBraceStatement < Statement
    REGEX = RegularExpressions::OPEN_BRACE

    def create_elements(parent_node, lines)
      symbol_node = document.create_element(SYMBOL, OPEN_BRACE)

      parent_node << symbol_node

      lines.sub(REGEX, '')
    end
  end
end
