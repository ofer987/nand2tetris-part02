# frozen_string_literal: true

module JackCompiler
  class NewArrayAssignmentExpression
    class << self
      def execution_node?(xml_node)
        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::NEW_ARRAY_TYPE
      end
    end

    def initialize(xml_node, variable:, _offset:)
      @xml_node = xml_node
      @variable = variable

      self.expression_list_node = "> #{Statement::TERM_STATEMENT} > #{Statement::EXPRESSION_LIST}"
      #
      # @symbol = Utils::XML.find_child_nodes_with_css_selector(xml_node, "> #{Statement::SYMBOL}")
      #   .map(&:text)
      #   .map(&:strip)
      #   .first

      variable.value = Memory::NULL_VALUE
    end

    def emit_vm_code(*)
      array_size = expression_list_node.parameters.first.to_i

      <<~VM_CODE
        push constant #{array_size}
        call Array.new 1
      VM_CODE
    end

    def calculate(objects); end

    private

    def expression_list_node=(css_selector)
      xml_nodes = Array(Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector))

      @expression_list_node = xml_nodes
        .map { |node| Utils::XML.convert_to_jack_node(node) }
        .first
    end

    attr_reader :xml_node, :variable, :expression_list_node
  end
end
