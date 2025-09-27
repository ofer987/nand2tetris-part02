# frozen_string_literal: true

module JackCompiler
  class ExecutionExpressionNode < ExpressionNode
    REGEX = RegularExpressions::EXECUTION_EXPRESSION_STATEMENT

    attr_reader :object, :method, :symbol, :expression_list_node

    def initialize(xml_node)
      super(xml_node)

      @object, @method = find_child_nodes_with_css_selector(
        "> #{Statement::TERM_STATEMENT} > #{Statement::IDENTIFIER}"
      )[0..1]
        .map(&:text)

      self.expression_list_node = "> #{Statement::TERM_STATEMENT} > #{Statement::EXPRESSION_LIST}"
        .first

      @symbol = find_child_nodes_with_css_selector("> #{Statement::SYMBOL}")
        .map(&:text)
        .first
    end

    def emit_vm_code
      <<~VM_CODE
        call #{object}.#{method} #{expression_list_node.size}
      VM_CODE
    end

    private

    def expression_list_node=(css_selector)
      xml_nodes = Array(find_child_nodes_with_css_selector(css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
    end
  end
end
