# frozen_string_literal: true

module JackCompiler
  class ReturnNode < Node
    NODE_NAME = Statement::RETURN_STATEMENT
    OBJECT_POINTER = 'this'

    attr_reader :value

    def initialize(xml_node, options = {})
      super(xml_node, options)

      self.value = Statement::IDENTIFIER
      self.memory_scope = options[:memory_scope]
    end

    def emit_vm_code
      if value == OBJECT_POINTER
        <<~VM_CODE
          push pointer 0
          return
        VM_CODE
      elsif value.match?(/^\d+$/)
        <<~VM_CODE
          push constant #{value}
          return
        VM_CODE
      else
        memory_scope[value].read_memory
      end
    end

    private

    def value=(val)
      value_node = find_child_nodes(val).first

      @value = '0'
      @value = value_node.text.strip unless value_node.nil?
    end

    attr_accessor :memory_scope
  end
end
