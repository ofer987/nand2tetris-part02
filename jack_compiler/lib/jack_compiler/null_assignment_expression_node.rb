# frozen_string_literal: true

module JackCompiler
  class NullAssignmentExpressionNode < Node
    class << self
      def execution_node?(xml_node)
        null_node_text = xml_node
          .find_child_nodes_with_css_selector("> #{Statement::EXPRESSION_STATEMENT} > #{Statement::TERM_STATEMENT} > #{Statement::NULL_CONSTANT}")
          .map(&:text)
          .first

        null_node_text == 'null'
      end
    end

    NODE_NAME = ''
    REGEX = RegularExpressions::NULL_CONSTANT_ASSIGNMENT

    def value
      0
    end

    def initialize(xml_node, memory:)
      super(xml_node, {})

      @memory = memory
    end

    def emit_vm_code
      "push constant #{value}"
    end
  end
end
