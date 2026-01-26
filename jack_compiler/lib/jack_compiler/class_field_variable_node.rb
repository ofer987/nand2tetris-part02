# frozen_string_literal: true

module JackCompiler
  class ClassFieldVariableNode < VariableNode
    NODE_NAME = Statement::CLASS_FIELD_VAR_DESCRIPTION

    def kind
      Memory::Kind::FIELD
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)
    end

    def emit_vm_code
      ''
    end
  end
end
