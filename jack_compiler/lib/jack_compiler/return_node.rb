# frozen_string_literal: true

module JackCompiler
  class ReturnNode < Node
    NODE_NAME = Statement::RETURN_STATEMENT

    attr_reader :value

    def initialize(xml_node, options = {})
      super(xml_node, options)

      self.value = "> #{Statement::IDENTIFIER}"
    end

    def emit_vm_code
      <<~VM_CODE
        push constant #{value}
        return
      VM_CODE
    end

    def value=(val)
      value_node = find_child_nodes(val).first

      @value = 0
      @value = value_node.text unless value_node.nil?
    end
  end
end
