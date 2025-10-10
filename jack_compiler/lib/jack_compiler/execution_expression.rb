# frozen_string_literal: true

module JackCompiler
  class ExecutionExpression
    class << self
      def execution_node?(_xml_node, memory:)
        memory.type == Memory::CLASS
      end
    end

    NODE_NAME = ''
    REGEX = RegularExpressions::EXECUTION_EXPRESSION_STATEMENT

    attr_reader :object, :method, :symbol, :expression_list_node

    def initialize(xml_node, memory:)
      @xml_node = xml_node
      @memory = memory

      @object, @method = Utils::XML.find_child_nodes_with_css_selector(
        xml_node,
        "> #{Statement::TERM_STATEMENT} > #{Statement::IDENTIFIER}"
      )[0..1]
        .map(&:text)

      self.expression_list_node = "> #{Statement::TERM_STATEMENT} > #{Statement::EXPRESSION_LIST}"

      @symbol = Utils::XML.find_child_nodes_with_css_selector(xml_node, "> #{Statement::SYMBOL}")
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
      xml_nodes = Array(Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    attr_reader :xml_node
  end
end
