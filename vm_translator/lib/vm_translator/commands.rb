#!/usr/bin/env ruby
# frozen_string_literal: true

module VMTranslator
  class Commands
    # Labels
    LABEL_REGEX = /^label (\S+)/
    GO_TO_IF_REGEX = /^if-goto (\S+)/
    GO_TO_NOW_REGEX = /^goto (\S+)/

    # RAM
    CONSTANT_REGEX = /constant (\d+)/
    LOCAL_REGEX = /local (\d+)/
    ARGUMENT_REGEX = /argument (\d+)/
    THIS_REGEX = /this (\d+)/
    THAT_REGEX = /that (\d+)/
    TEMP_REGEX = /temp (\d+)/
    POINTER_REGEX = /pointer (\d+)/
    STATIC_REGEX = /static (\d+)/

    # Stack commands
    PUSH_REGEX = /^push (.+)/
    POP_REGEX = /^pop (.+)/

    # Logical commands
    ADD_REGEX = /^add/
    SUB_REGEX = /^sub/
    EQ_REGEX = /^eq/
    LT_REGEX = /^lt/
    GT_REGEX = /^gt/
    NEG_REGEX = /^neg/
    AND_REGEX = /^and/
    OR_REGEX = /^or/
    NOT_REGEX = /^not/

    # Functions
    FUNCTION_REGEX = /^function (.+) (\d+)/
    CALL_REGEX = /^call (.+) (\d+)/
    RETURN_REGEX = /return/

    STATEMENTS = [
      LABEL_REGEX,
      GO_TO_IF_REGEX,
      GO_TO_NOW_REGEX,
      PUSH_REGEX,
      POP_REGEX,
      ADD_REGEX,
      SUB_REGEX,
      EQ_REGEX,
      LT_REGEX,
      GT_REGEX,
      NEG_REGEX,
      AND_REGEX,
      OR_REGEX,
      NOT_REGEX,
      FUNCTION_REGEX,
      CALL_REGEX
    ].freeze

    def self.statement?(line)
      STATEMENTS.each do |statement|
        return true if line.match? statement
      end

      false
    end
  end
end
