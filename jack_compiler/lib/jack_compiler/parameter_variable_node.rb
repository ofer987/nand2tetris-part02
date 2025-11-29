# frozen_string_literal: true

module JackCompiler
  class ParameterVariableNode < VariableNode
    NODE_NAME = Statement::EXPRESSION_LIST

    def kind
      Memory::Kind::ARGUMENT
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)
    end

    def emit_vm_code
      ''
    end
  end
end
