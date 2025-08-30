# frozen_string_literal: true

module JackCompiler
  class RegularExpressions
    # PARAMETER_LIST = /\S+,\s*(\S+)
    # IF = /(if)\s*(\(.+)/
    # EXPRESSION = /\(\s*(\S+)\s*(\S+)\s*(\S+)/
    LET_STATEMENT = /(let)\s+(\S+)\s*(=)\s*([^;]+)(;)/
    ARRAY_EXPRESSION = /([^\[]+)(\[)(\d+)(\])/
    STRING_CONSTANT_ASSIGNMENT = /"(.*)"/
    INTEGER_CONSTANT_ASSIGNMENT = /(\d+)/
    NULL_CONSTANT_ASSIGNMENT = /(null)/
    VARIABLE_ASSIGNMENT = /(.+)/
    OPERATIONS = %r{[*\-+/|]}
    UNARY_OPERATION_EXPRESSION_REGEX = /\((#{OPERATIONS})\s*([#{INTEGER_CONSTANT_ASSIGNMENT}#{VARIABLE_ASSIGNMENT}])\)/

    # FIXME: string does not allow spaces
    # UNARY operation left & right
    BINARY_OPERATION_EXPRESSION_REGEX_01 = /(\(.+\))\s*(#{OPERATIONS})\s*(\(.+\))/
    # UNARY operation left only
    BINARY_OPERATION_EXPRESSION_REGEX_02 = /(\(.+\))\s*(#{OPERATIONS})\s*([^\s]+)/
    # UNARY operation right only
    BINARY_OPERATION_EXPRESSION_REGEX_03 = /([^\s]+)\s*(#{OPERATIONS})\s*(\(.+\))/
    # No UNARY operations
    BINARY_OPERATION_EXPRESSION_REGEX_04 = /([^\s]+)\s*(#{OPERATIONS})\s*([^\s]+)/

    CLASS = /class\s+(\S+)\s+{/
    FUNCTION = /(function)\s+(\S+)\s+(\S+)\(([^)]*)\)\s*/
    SUBROUTINE_BODY = //
    ENDING_STATEMENT = /;/
    OPEN_BRACE = /({)/
    CLOSE_BRACE = /}/
    CLASS_VAR_STATEMENT = /(static)\s+(\S+)\s+(\S+)\s*;/
    VAR_STATEMENT = /(var)\s+(\S+)\s+([^;]+)\s*(;)/
    DO_STATEMENT = /(do)\s*(\S+)\s*(;)/
    ASSIGNMENT_EXPRESSION_STATEMENT = /(\S+)(\.)(\S+)(\()([^)]*)(\))\s*/
    EXECUTION_EXPRESSION_STATEMENT = /(\S+)(\.)(\S+)(\()([^)]*)(\))\s*/
    INTEGER_EXPRESSION_STATEMENT = /(\S+)\s*(;)/
    NULL_EXPRESSION_STATEMENT = /(null)\s*(;)/
    RETURN_STATEMENT = /(return)\s*(\S+)(;)/
    EMPTY_RETURN_STATEMENT = /(return)\s*(;)/
    ARGUMENT_STATEMENT = /([^,]+),?/
    IF_STATEMENT_REGEX = /(if)\s*(\()\s*(\S+)\s*(\))\s*({)/
    ELSE_STATEMENT_REGEX = /(else)\s*({)/
    STATEMENTS_REGEX = /if|let|do|return/
  end
end
