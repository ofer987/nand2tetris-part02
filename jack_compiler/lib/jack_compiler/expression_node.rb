# frozen_string_literal: true

module JackCompiler
  class ExpressionNode < Node
    NODE_NAME = Statement::EXPRESSION_STATEMENT
    EXPRESSION_NODE_CLASSES = [
      InfixEvaluatorAssignmentExpression,
      StringAssignmentExpression,
      NullAssignmentExpression,
      ExecutionExpression,
      IntegerAssignmentExpression
    ].freeze

    def initialize(xml_node, options)
      super(xml_node, options)

      @memory = options[:memory]

      init_execution_expression_node

    end

    def calculate(objects)
      internal_expression_node.calculate(objects)
    end

    def emit_vm_code(objects)
      internal_expression_node.emit_vm_code(objects)
    end

    private

    def init_execution_expression_node
      internal_expression_class = EXPRESSION_NODE_CLASSES
        .select { |klazz| klazz.execution_node?(xml_node, memory:) }
        .first

      @internal_expression_node = internal_expression_class.new(xml_node, memory:)
    end

    attr_reader :internal_expression_node, :memory
  end
end
