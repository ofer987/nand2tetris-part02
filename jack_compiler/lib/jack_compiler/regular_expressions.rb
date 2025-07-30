# frozen_string_literal: true

module JackCompiler
  class RegularExpressions
    IF = /(if)\s*(\(.+)/
    EXPRESSION = /\(\s*(\S+)\s*(\S+)\s*(\S+)/
    LET_STATEMENT = /let\s+(\S+)\s*(=)\s*(\S+)\s*(;)/
    CLASS = /class\s+(\S+)\s+{/
    FUNCTION = /function\s+(\S+)\s+(\S+)\((.*)\).+{/
    ENDING_STATEMENT = /;/
    OPEN_BRACE = /{/
    CLOSE_BRACE = /}/
    CLASS_VAR_STATEMENT = /(static)\s+(\S+)\s+(\S+)\s*;/
    VAR_STATEMENT = /(var)\s+(\S+)\s+(\S+)\s*(;)/
  end
end
