# frozen_string_literal: true

module JackCompiler
  class LetStatement < Statement
    REGEX = RegularExpressions::LET_STATEMENT

    # rubocop:disable Metrics/AbcSize
    def create_elements(parent_node, lines)
      result = lines.match(REGEX)
      result_node = document.create_element(LET_STATEMENT)

      parent_node << result_node

      keyword_node = document.create_element(KEYWORD, result[1])
      result_node << keyword_node

      parent_node << result_node

      value_node = document.create_element(IDENTIFIER, result[2])
      result_node << value_node

      symbol_node = document.create_element(SYMBOL, result[3])
      result_node << symbol_node

      expression_node = document.create_element(EXPRESSION_STATEMENT)
      result_node << expression_node

      value = result[4]
      if array? value
        next_statements(expression_node, value, [NewArrayAssignmentStatement])
      elsif reference? value
        next_statements(expression_node, value, [NewClassAssignmentStatement])
      elsif expression_contains_init_instruction? value
        raise "'#{value} contains an initializer!"
      else
        next_statements(expression_node, value, next_expression_classes)
      end

      symbol_node = document.create_element(SYMBOL, result[5])
      result_node << symbol_node

      lines.sub(REGEX, '')
    end
    # rubocop:enable Metrics/AbcSize

    private

    def array?(value)
      /^#{RegularExpressions::ARRAY_NEW_EXPRESSION}$/.match? value
    end

    def reference?(value)
      /^#{RegularExpressions::CLASS_NEW_EXPRESSION}$/.match? value
    end

    def expression_contains_init_instruction?(value)
      RegularExpressions::CLASS_NEW_EXPRESSION.match? value
    end

    def next_expression_classes
      [
        AssignmentExpressionStatement,
        BinaryAssignmentStatement01,
        BinaryAssignmentStatement02,
        BinaryAssignmentStatement03,
        BinaryAssignmentStatement04,
        UnaryAssignmentStatement,
        StringAssignmentStatement,
        NullAssignmentStatement,
        VariableAssignmentStatement,
        WhileStatement
      ]
    end
  end
end
