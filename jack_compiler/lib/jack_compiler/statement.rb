# frozen_string_literal: true

module JackCompiler
  class Statement
    # Default NODE_NAME is empty
    NODE_NAME = ''

    CLASS = 'class'
    KEYWORD = 'keyword'
    IDENTIFIER = 'identifier'
    PARAMETER_LIST = 'parameterList'
    PARAMETER = 'parameter'
    OPEN_PARENTHESIS = '('
    CLOSE_PARENTHESIS = ')'
    OPEN_BRACE = '{'
    CLOSE_BRACE = '}'
    SYMBOL = 'symbol'
    CLASS_VAR_DESCRIPTION = 'classVarDec'
    SUBROUTINE_DESCRIPTION = 'subroutineDec'
    SUBROUTINE_BODY = 'subroutineBody'
    VAR_DESCRIPTION = 'varDec'
    SEMI_COLON = ';'
    EQUAL_SIGN = '='
    IF_STATEMENT = 'ifStatement'
    ELSE_STATEMENT = 'else'
    LET_STATEMENT = 'letStatement'
    LET_KEYWORD = 'let'
    DO_STATEMENT = 'doStatement'
    DO_KEYWORD = 'do'
    RETURN_STATEMENT = 'returnStatement'
    EXPRESSION_STATEMENT = 'expression'
    TERM_STATEMENT = 'term'
    EXPRESSION_LIST = 'expressionList'
    ARGUMENT_STATEMENT = 'argument'
    STATEMENTS_STATEMENT = 'statements'
    COMMA = ','

    EVALUATION_STATEMENT = 'evaluation'
    EVALUATION_TYPE_STATEMENT = 'evaluation_type'

    BOOLEAN_CONSTANT = 'booleanConstant'
    NULL_CONSTANT = 'nullConstant'
    INTEGER_CONSTANT = 'integerConstant'
    STRING_CONSTANT = 'stringConstant'
    REFERENCE_VARIABLE = 'referenceVariable'

    VARIABLE_CONSTANT = 'identifier'
    INFIX_EXPRESSION = 'infix_expression'
    LOCAL_MEMORY = 'var'
    STATIC_MEMORY = 'static'
    FIELD_MEMORY = 'field'
    ARRAY_CLASS = 'Array'
    ARRAY_VALUE = 'array'
    EXECUTION_TYPE = 'execution'

    attr_reader :document

    def initialize(document)
      @document = document
    end

    def create_elements(parent_node, lines)
      raise NotImplementedError
    end

    private

    def next_statement(parent_node, next_lines, next_classes)
      next_lines = next_lines.strip

      return '' if next_lines.blank?
      return next_lines if next_classes.blank?

      # Interpret code, line by line in descending order
      next_klass = next_classes
        .select { |klass| next_lines.match?(/^#{klass::REGEX}/) }
        .first
      return next_lines if next_klass.blank?

      next_klass
        .new(document)
        .create_elements(parent_node, next_lines)
        .strip
    end

    def next_statements(parent_node, next_lines, next_classes)
      next_lines = next_lines.strip

      loop do
        break if next_lines.blank?
        break if next_classes.blank?

        # Interpret code, line by line in descending order
        next_klass = next_classes
          .select { |klass| next_lines.match?(/^#{klass::REGEX}/) }
          .first
        break if next_klass.blank?

        next_lines = next_klass
          .new(document)
          .create_elements(parent_node, next_lines)
          .strip
      end

      next_lines
    end
  end
end
