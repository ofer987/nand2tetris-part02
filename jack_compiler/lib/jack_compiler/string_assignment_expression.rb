# frozen_string_literal: true

module JackCompiler
  class StringAssignmentExpression
    class << self
      def execution_node?(xml_node, memory:)
        return false if memory.type != Memory::CLASS

        Utils::XML.find_child_nodes_with_css_selector(
          xml_node,
          "> #{Statement::TERM_STATEMENT} > #{Statement::STRING_CONSTANT}"
        ).any?
      end
    end

    attr_reader :value

    def initialize(xml_node, memory:)
      @xml_node = xml_node
      @memory = memory

      self.value = "> #{Statement::EXPRESSION_STATEMENT} > #{Statement::TERM_STATEMENT} > #{Statement::STRING_CONSTANT}"
    end

    def emit_vm_code
      characters.map do |character|
        <<~VM_CODE
          call String.appendChar #{memory.index}
          push constant #{character.ord}
        VM_CODE
      end
      "push constant #{value}"
    end

    private

    def characters
      @characters ||= value.chars
    end

    def value=(css_selector)
      @value = Utils::XML.find_child_nodes_with_css_selector(xml_node, css_selector)
        .map(&:text)
        .map(&:strip)
        .first
    end

    attr_reader :xml_node
  end
end
