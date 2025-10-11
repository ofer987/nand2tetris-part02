# frozen_string_literal: true

module JackCompiler
  class ExpressionNode < Node
    NODE_NAME = Statement::EXPRESSION_STATEMENT
    EXPRESSION_NODE_CLASSES = [
      NullAssignmentExpression,
      ExecutionExpression,
      StringAssignmentExpression,
      IntegerAssignmentExpression
    ].freeze

    def initialize(xml_node, options)
      super(xml_node, options)

      @memory = options[:memory]
      init_execution_expression_node
    end

    def emit_vm_code
      internal_expression_node.emit_vm_code
    end

    private

    def init_execution_expression_node
      internal_expression_class = EXPRESSION_NODE_CLASSES
        .select { |klazz| klazz.execution_node?(xml_node, memory: memory) }
        .first

      @internal_expression_node = internal_expression_class.new(xml_node, memory: memory)
    end

    attr_reader :internal_expression_node, :memory
  end
end
