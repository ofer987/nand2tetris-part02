# frozen_string_literal: true

module JackCompiler
  class RegularExpressions
    IF = /(if)\s*(\(.+)/
    # EXPRESSION = /\(\s*(\S+)\s*(\S+)\s*(\S+)/
    LET_STATEMENT = /(let)\s+(\S+)\s*(=)\s*(\S+)\s*(;)/
    CLASS = /class\s+(\S+)\s+{/
    FUNCTION = /(function)\s+(\S+)\s+(\S+)\(([^)]*)\)\s*/
    SUBROUTINE_BODY = //
    ENDING_STATEMENT = /;/
    OPEN_BRACE = /({)/
    CLOSE_BRACE = /}/
    CLASS_VAR_STATEMENT = /(static)\s+(\S+)\s+(\S+)\s*;/
    VAR_STATEMENT = /(var)\s+(\S+)\s+(\S+)\s*(;)/
    DO_STATEMENT = /(do)\s+(\S+)(\.)(S+)(\()(\S+)(\))\s*(;)/
    EXPRESSION_STATEMENT_EXECUTION = /(\S+)(\.)(\S)\((.*)\)\s*(;)/
    EXPRESSION_STATEMENT_INTEGER = /(\S+)\s*(;)/
    EXPRESSION_STATEMENT_NUL = /(null)\s*(;)/
    RETURN_STATEMENT = /(return)\s*(\S+)(;)/
    EMPTY_RETURN_STATEMENT = /(return)\s*(;)/
  end
end
