# frozen_string_literal: true

module JackCompiler
  class ExpressionNode < Node
    NODE_NAME = Statement::EXPRESSION_STATEMENT
    EXPRESSION_NODE_CLASSES = [
      ExecutionExpressionNode,
      NullAssignmentExpressionNode,
      StringAssignmentExpressionNode
    ].freeze

    def initialize(xml_node, memory:)
      super(xml_node, {})

      @memory = memory
      init_execution_expression_node
    end

    def emit_vm_code
      internal_expression_node.emit_vm_code
    end

    private

    def init_execution_expression_node
      # TODO: change to switch or if/else using regex
      @internal_expression_node = ExecutionExpressionNode.new(xml_node, options)
      @internal_expression_node = StringAssignmentExpressionNode.new(xml_node, memory_index: memory.index)
    end

    attr_reader :internal_expression_node, :memory
  end
end
