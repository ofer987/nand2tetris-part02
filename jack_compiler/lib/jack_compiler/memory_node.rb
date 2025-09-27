# frozen_string_literal: true

module JackCompiler
  class MemoryNode < Node
    NODE_NAME = ''

    def memory_index
      raise NotImplementedError
    end

    def memory_type
      raise NotImplementedError
    end

    def initialize(xml_node, options = {})
      super(xml_node, options)
    end

    def emit_vm_code
      raise NotImplementedError
    end
  end
end
