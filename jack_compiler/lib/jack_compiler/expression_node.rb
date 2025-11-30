# frozen_string_literal: true

module JackCompiler
  class ExpressionNode < Node
    NODE_NAME = Statement::EXPRESSION_STATEMENT
    EXPRESSION_NODE_CLASSES = [
      InfixEvaluatorAssignmentExpression,
      StringAssignmentExpression,
      NullAssignmentExpression,
      IntegerAssignmentExpression,
      ExecutionExpression
    ].freeze

    def initialize(xml_node, options)
      super(xml_node, options)

      @variable = options[:variable]

      init_execution_expression_node
    end

    # TODO: rename to memory_scope
    def calculate(objects)
      internal_expression_node.calculate(objects)
    end

    def emit_vm_code(objects)
      internal_expression_node.emit_vm_code(objects)
    end

    private

    def init_execution_expression_node
      internal_expression_class = EXPRESSION_NODE_CLASSES
        .select { |klazz| klazz.execution_node?(xml_node) }
        .first

      @internal_expression_node = internal_expression_class.new(xml_node, variable:)
    end

    attr_reader :internal_expression_node, :variable
  end
end
