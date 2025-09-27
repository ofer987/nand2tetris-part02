# frozen_string_literal: true

module JackCompiler
  class StatementNode < Node
    NODE_NAME = ''

    def initialize(xml_node, options = {})
      super(xml_node, options)
    end

    def emit_vm_code
      raise NotImplementedError
    end
  end
end
