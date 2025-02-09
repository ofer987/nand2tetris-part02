# frozen_string_literal: true

module JackCompiler
  class LetStatement < Statement
    REGEX = RegularExpressions::LET
  end
end
