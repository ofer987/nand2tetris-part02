# frozen_string_literal: true

module JackCompiler
  class ClassVariableNode < VariableNode
    NODE_NAME = Statement::CLASS_VAR_DESCRIPTION

    def kind
      return Memory::Kind::FIELD if @keywords.first.text == Statement::FIELD_MEMORY

      Memory::Kind::STATIC
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)
    end

    def emit_vm_code
      ''
    end
  end
end
