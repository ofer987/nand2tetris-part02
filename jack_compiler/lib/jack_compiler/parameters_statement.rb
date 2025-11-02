# frozen_string_literal: true

module JackCompiler
  class ParametersStatement < Statement
    REGEX = RegularExpressions::PARAMETER_LIST

    def create_elements(parent_node, lines)
      while lines.match? REGEX
        result = lines.match(REGEX)

        result_node = document.create_element(TERM_STATEMENT)
        parent_node << result_node

        keyword_node = document.create_element(KEYWORD, Statement::ARGUMENT_STATEMENT)
        result_node << keyword_node

        node =
          if result[1].start_with?(/[A-Z]/)
            document.create_element(IDENTIFIER, result[1])
          else
            document.create_element(KEYWORD, result[1])
          end
        result_node << node

        identifer_node = document.create_element(IDENTIFIER, result[2])
        result_node << identifer_node

        lines = lines.sub(REGEX, '')
      end

      ''
    end
  end
end
