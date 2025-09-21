# frozen_string_literal: true

module JackCompiler
  class MemoryNode < Node
    REGEX = //
    NODE_NAME = ''

    attr_reader :ram_index, :memory_type

    def initialize(xml_node, ram_index, memory_type)
      super(xml_node)

      @ram_index = ram_index
      @memory_type = memory_type
    end

    def emit_vm_code
      raise NotImplementedError
    end

    private

    attr_writer :ram_index, :memory_type
  end
end
