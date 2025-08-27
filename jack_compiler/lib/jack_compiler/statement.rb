# frozen_string_literal: true

module JackCompiler
  class Statement
    CLASS = 'class'
    KEYWORD = 'keyword'
    IDENTIFIER = 'identifier'
    PARAMETER_LIST = 'parameterList'
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
    LET_STATEMENT = 'letStatement'
    LET_KEYWORD = 'let'
    DO_STATEMENT = 'doStatement'
    DO_KEYWORD = 'do'
    RETURN_STATEMENT = 'returnStatement'
    EXPRESSION_STATEMENT = 'expression'
    TERM_STATEMENT = 'term'
    EXPRESSION_LIST = 'expressionList'
    ARGUMENT_STATEMENT = 'argument'
    STATEMENTS = 'statements'
    COMMA = ','

    attr_reader :document

    def initialize(document)
      @document = document
    end

    def create_elements(parent_node, lines)
      raise NotImplementedError
    end

    private

    def next_statements(parent_node, next_lines, next_classes)
      next_lines = next_lines.strip

      # binding.pry
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
