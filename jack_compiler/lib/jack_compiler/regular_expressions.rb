# frozen_string_literal: true

module JackCompiler
  class RegularExpressions
    IF = /(if)\s*(\(.+)/
    EXPRESSION = /\(\s*(\S+)\s*(\S+)\s*(\S+)/
    LET = /let\s+([A-Za-z\-_]+)\s*(=)\s*"(.+)"\s*(;)/
    CLASS = /class\s+(\S+)\s+/
    ENDING_STATEMENT = /;/
    OPEN_BRACE = /{/
    CLOSE_BRACE = /}/
  end
end
