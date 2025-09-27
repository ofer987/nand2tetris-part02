# frozen_string_literal: true

module JackCompiler
  class ExecutionExpressionNode < ExpressionNode
    REGEX = RegularExpressions::EXECUTION_EXPRESSION_STATEMENT

    attr_reader :object, :method, :symbol, :parameters_node

    def initialize(xml_node)
      super(xml_node)

      @object, @method = find_child_nodes_with_css_selector(
        "> #{Statement::TERM_STATEMENT} > #{Statement::IDENTIFIER}"
      )[0..1]

      @parameters_node = find_child_nodes_with_css_selector(
        "> #{Statement::TERM_STATEMENT} > #{Statement::EXPRESSION_LIST}"
      ).first

      @symbol = find_child_nodes_with_css_selector("> #{Statement::SYMBOL}").first
    end

    def emit_vm_code
      <<~VM_CODE
        call #{object}.#{method}.#{parameters_node.parameters.size}
      VM_CODE
    end
  end
end
