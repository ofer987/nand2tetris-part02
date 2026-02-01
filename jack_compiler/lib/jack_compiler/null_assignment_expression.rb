# frozen_string_literal: true

module JackCompiler
  class NullAssignmentExpression
    class << self
      def execution_node?(xml_node)
        evaluation_node = Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::EVALUATION_TYPE_STATEMENT}"
        ).first

        return false if evaluation_node.blank?

        evaluation_node.text == Statement::NULL_CONSTANT
      end
    end

    def value
      0
    end

    def initialize(xml_node, variable:)
      @xml_node = xml_node
      @variable = variable

      variable.value = 0
    end

    def emit_vm_code(_objects)
      <<~VM_CODE
        push constant #{value}
        #{variable.assign_value_from_stack}
      VM_CODE
    end

    def calculate(objects); end

    private

    attr_reader :variable
  end
end
