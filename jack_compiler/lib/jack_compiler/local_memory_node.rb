# frozen_string_literal: true

module JackCompiler
  class LocalMemoryNode < MemoryNode
    REGEX = RegularExpressions::FUNCTION
    NODE_NAME = Statement::SUBROUTINE_DESCRIPTION

    attr_reader :object_type, :object_name

    def initialize(xml_node, ram_index)
      super(xml_node, ram_index, 'local')

      @object_type = find_child_nodes(Statement::KEYWORD).first

      identifiers = find_child_nodes(Statement::IDENTIFIER)
      @object_type = identifiers[0]
      # TODO: What if there are multiple objects?
      @object_name = identifiers[1]
    end

    def emit_vm_code
      <<~VM_CODE
        pop local #{ram_index}
      VM_CODE
    end

    private

    def local_memory
      return @local_memory if defined? @local_memory

      if @local_memory_nodes.blank?
        @local_memory = []

        return @local_memory
      end

      @local_me
    end
  end
end
