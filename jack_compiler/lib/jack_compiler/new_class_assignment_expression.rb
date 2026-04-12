# frozen_string_literal: true

module JackCompiler
  class NewClassAssignmentExpression
    class << self
      def execution_node?(xml_node)
        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::NEW_CLASS_TYPE
      end
    end

    def initialize(xml_node, params)
      @xml_node = xml_node
      @variable = params[:variable]

      self.expression_list_node = "> #{Statement::TERM_STATEMENT} > #{Statement::EXPRESSION_LIST}"

      variable.value = Memory::NULL_VALUE
    end

    def emit_vm_code(memory_scope)
      array_size = expression_list_node.parameters.size

      <<~VM_CODE
        #{expression_list_node.emit_vm_code(memory_scope)}
        call #{variable.type}.new #{array_size}
      VM_CODE
    end

    def calculate(memory_scope); end

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
