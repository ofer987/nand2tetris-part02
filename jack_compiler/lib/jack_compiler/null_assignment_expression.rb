# frozen_string_literal: true

module JackCompiler
  class NullAssignmentExpression < Node
    class << self
      def execution_node?(xml_node, _options)
        null_node_text = Utils::XML
          .find_child_nodes_with_css_selector(
            xml_node,
            "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::TERM_STATEMENT} > #{Statement::NULL_CONSTANT}"
          ).map(&:text)
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
