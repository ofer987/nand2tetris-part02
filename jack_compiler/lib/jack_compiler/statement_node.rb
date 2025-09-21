# frozen_string_literal: true

module JackCompiler
  class StatementNode < Node
    REGEX = ''
    NODE_NAME = ''

    def initialize(xml_node, local_memory)
      super

      @local_memory = local_memory
    end

    def emit_vm_code
      raise NotImplementedError
    end

    protected

    attr_writer :local_memory
  end
end
