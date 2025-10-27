# frozen_string_literal: true

module JackCompiler
  class IntegerAssignmentExpression
    class << self
      def execution_node?(xml_node, memory:)
        return false if memory.type != Memory::PRIMITIVE

        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::INTEGER_CONSTANT
      end
    end

    attr_reader :value

    def initialize(xml_node, memory:)
      @xml_node = xml_node
      @memory = memory

      self.value = "> #{Statement::TERM_STATEMENT} > #{Statement::INTEGER_CONSTANT}"
      memory.value = value
    end

    def emit_vm_code
      "push constant #{value}"
    end

    private

    def value=(css_selector)
      @value = Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector)
        .map(&:text)
        .map(&:strip)
        .first
    end

    attr_reader :xml_node, :memory
  end
end
