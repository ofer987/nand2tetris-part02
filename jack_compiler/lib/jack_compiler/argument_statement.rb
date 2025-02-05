# frozen_string_literal: true

module JackCompiler
  class ArgumentStatement < Statement
    REGEX = RegularExpressions::ARGUMENT_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(ARGUMENT_STATEMENT, result[1])
      parent_node << result_node

      lines.sub(REGEX, '')
    end

    private

    def next_classes
      []
    end
  end
end
