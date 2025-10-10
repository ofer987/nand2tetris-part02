# frozen_string_literal: true

module JackCompiler
  class IntegerAssignmentExpressionNode < Node
    class << self
      def execution_node?(xml_node, memory:)
        return false if memory.type != Memory::PRIMITIVE

        xml_node
          .find_child_nodes_with_css_selector("> #{Statement::EXPRESSION_STATEMENT} > #{Statement::TERM_STATEMENT} > #{Statement::INTEGER_CONSTANT}")
          .any?
      end
    end

    NODE_NAME = ''
    REGEX = RegularExpressions::INTEGER_CONSTANT_ASSIGNMENT

    attr_reader :value

    def initialize(xml_node, memory:)
      super(xml_node, {})

      @memory = memory
      self.value = "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::TERM_STATEMENT} > #{Statement::INTEGER_CONSTANT}"
    end

    def emit_vm_code
      "push constant #{value}"
    end

    private

    def value=(css_selector)
      @value = find_child_nodes_with_css_selector(css_selector)
        .map(&:text)
        .first
    end
  end
end
