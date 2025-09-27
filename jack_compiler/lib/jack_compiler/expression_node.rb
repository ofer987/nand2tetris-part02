# frozen_string_literal: true

module JackCompiler
  class ExpressionNode < Node
    NODE_NAME = Statement::EXPRESSION_STATEMENT

    def initialize(xml_node, options = {})
      super(xml_node, options)
    end

    def emit_vm_code
      raise NotImplementedError
    end
  end
end
