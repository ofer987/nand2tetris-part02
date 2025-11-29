# frozen_string_literal: true

module JackCompiler
  class VarStatementNode < VariableNode
    NODE_NAME = Statement::VAR_DESCRIPTION

    def kind
      Memory::Kind::LOCAL
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)
    end

    def emit_vm_code
      ''
    end
  end
end
