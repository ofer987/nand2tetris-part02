# frozen_string_literal: true

module JackCompiler
  class NullAssignmentExpression
    class << self
      def execution_node?(xml_node, _options)
        null_node_text = Utils::XML
          .find_child_nodes_with_css_selector(
            xml_node,
            "> #{Statement::TERM_STATEMENT} > #{Statement::NULL_CONSTANT}"
          )
          .map(&:text)
          .map(&:strip)
          .first

        null_node_text == Statement::NULL_VALUE
      end
    end

    def value
      0
    end

    def initialize(xml_node, memory:)
      @xml_node = xml_node
      @memory = memory
    end

    def emit_vm_code
      "push constant #{value}"
    end
  end
end
