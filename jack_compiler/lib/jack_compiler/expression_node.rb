# frozen_string_literal: true

module JackCompiler
  class ExpressionNode < Node
    REGEX = //
    NODE_NAME = Statement::EXPRESSION_STATEMENT

    def emit_vm_code
      raise NotImplementedError
    end
  end
end
