# frozen_string_literal: true

module JackCompiler
  class NullAssignmentExpressionNode < Node
    NODE_NAME = ''
    REGEX = RegularExpressions::NULL_CONSTANT_ASSIGNMENT

    def value
      0
    end

    def emit_vm_code
      "push constant #{value}"
    end
  end
end
