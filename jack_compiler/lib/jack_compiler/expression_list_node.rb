# frozen_string_literal: true

module JackCompiler
  class ExpressionListNode < Node
    # TODO: fix me
    REGEX = //
    NODE_NAME = Statement::EXPRESSION_LIST

    attr_reader :arguments

    def initialize(xml_node)
      super(xml_node)

      @parameters = []
    end

    def emit_vm_code
      <<~VM_CODE
      VM_CODE
    end
  end
end
