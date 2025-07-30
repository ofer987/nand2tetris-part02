# frozen_string_literal: true

module JackCompiler
  class RegularExpressions
    IF = /(if)\s*(\(.+)/
    EXPRESSION = /\(\s*(\S+)\s*(\S+)\s*(\S+)/
    LET = /let\s+([A-Za-z\-_]+)\s*(=)\s*"(.+)"\s*(;)/
    CLASS = /class\s+(\S+)\s+{/
    FUNCTION = /function\s+(\S+)\s+(\S+)\(\)/
    ENDING_STATEMENT = /;/
    OPEN_BRACE = /{/
    CLOSE_BRACE = /}/
    CLASS_VAR_STATEMENT = /(static)\s+(\S+)\s+(\S+)\s*;/
  end
end
