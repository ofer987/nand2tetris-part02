#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'

module VMTranslator
  class Commands
    LABEL_REGEX = /^label (\S+)/
    IF_GO_TO_REGEX = /^if-goto (\S+)/
    CONSTANT_REGEX = /constant (\d+)/
    LOCAL_REGEX = /local (\d+)/
    ARGUMENT_REGEX = /argument (\d+)/
    THIS_REGEX = /this (\d+)/
    THAT_REGEX = /that (\d+)/
    TEMP_REGEX = /temp (\d+)/
    POINTER_REGEX = /pointer (\d+)/
    STATIC_REGEX = /static (\d+)/
    PUSH_REGEX = /^push (.+)$/
    POP_REGEX = /^pop (.+)$/
    ADD_REGEX = /^add$/
    SUB_REGEX = /^sub$/
    EQ_REGEX = /^eq$/
    LT_REGEX = /^lt$/
    GT_REGEX = /^gt$/
    NEG_REGEX = /^neg$/
    AND_REGEX = /^and$/
    OR_REGEX = /^or$/
    NOT_REGEX = /^not$/

    STATEMENTS = [
      LABEL_REGEX,
      IF_GO_TO_REGEX,
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
      NOT_REGEX
    ].freeze

    def self.statement?(line)
      STATEMENTS.each do |statement|
        return true if line.match? statement
      end

      false
    end
  end
end
