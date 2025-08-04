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

    attr_reader :document

    def initialize(document)
      @document = document
    end

    def create_elements(parent_node, lines)
      raise NotImplementedError
    end

    protected

    def next_classes
      []
    end

    private

    def next_statements(parent_node, next_lines)
      # binding.pry
      loop do
        return if next_lines.blank?
        return if next_classes.blank?

        binding.pry
        next_klass = next_classes
          .select { |klass| klass::REGEX.match? next_lines }
          .first
        binding.pry
        return if next_klass.blank?

        next_lines = next_klass
          .new(document)
          .create_elements(parent_node, next_lines)
      end
    end
  end
end
