# frozen_string_literal: true

module JackCompiler
  class VariableStatement < Statement
    REGEX = RegularExpressions::VAR_STATEMENT
    # EXPRESSION_REGEX = RegularExpressions::EXPRESSION

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(VAR_DESCRIPTION)
      binding.pry

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      node =
        if result[2].start_with?(/[A-Z]/)
          document.create_element(IDENTIFIER, result[2])
        else
          document.create_element(KEYWORD, result[2])
        end
      result_node << node

      multiple_variable_nodes(result[3]).each do |variable_node|
        result_node << variable_node
      end
      binding.pry
      # result_node << identifier_node

      symbol_node = document.create_element(SYMBOL, SEMI_COLON)
      result_node << symbol_node

      # binding.pry
      lines.sub(REGEX, '')
    end

    private

    def multiple_variable_nodes(identifier)
      identifier
        .split(',')
        .map { |item| [IDENTIFIER, item] }
        .join([SYMBOL, COMMA])
        .map { |key, value| document.create_element(key, value) }
    end
  end
end
