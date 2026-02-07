# frozen_string_literal: true

module JackCompiler
  class ArgumentStatement < Statement
    REGEX = RegularExpressions::ARGUMENT_STATEMENT

    def create_elements(parent_node, lines)
      result = lines.match(REGEX)

      next_statements(parent_node, result[1], arugment_classes)

      lines.sub(REGEX, '')
    end

    private

    def arugment_classes
      [
        IntegerAssignmentStatement,
        StringAssignmentStatement,
        ArrayAssignmentStatement,
        BooleanAssignmentStatement,
        VariableAssignmentStatement,
        NullAssignmentStatement
      ]
    end
  end
end
