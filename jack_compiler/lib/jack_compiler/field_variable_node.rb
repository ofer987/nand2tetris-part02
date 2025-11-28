# frozen_string_literal: true

module JackCompiler
  class FieldVariableNode < Node
    NODE_NAME = Statement::CLASS_VAR_DESCRIPTION

    def memory_kind
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
