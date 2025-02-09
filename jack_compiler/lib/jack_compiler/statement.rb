# frozen_string_literal: true

module JackCompiler
  class Statement
    CLASS = 'class'
    KEYWORD = 'keyword'
    IDENTIFIER = 'identifier'
    OPEN_BRACE = '{'
    CLOSE_BRACE = '}'
    SYMBOL = 'symbol'
    CLASS_VAR_DESCRIPTION = 'classVarDec'
    SUBROUTINE_DESCRIPTION = 'subroutineDec'
    PARAMETER_LIST = 'parameterList'
    SUBROUTINE_BODY = 'subroutineBody'
    VAR_DESCRIPTION = 'varDec'

    attr_reader :document

    def initialize(document)
      @document = document
    end

    def create_elements(parent_node, lines)
      raise NotImplementedError
    end

    def next_statements
      raise NotImplementedError
    end
  end
end
